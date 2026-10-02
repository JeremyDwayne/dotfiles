import type { EngineInterface, Register } from 'claude-code'

import { ciSummary, classify, migrationNames, parseHost, parseLiveSha } from './classify'
import type { Risk } from './classify'

const PANE = 'prod-guard'
const POLL_SECONDS = '0.25'
const HOLD_LIMIT_MS = 10 * 60 * 1000
const COMMITS_SHOWN = 3

type Ship = {
  host: string
  live: string | null
  head: string
  branch: string
  /** `git log --oneline` lines from live to HEAD; null when the live version is unknown. */
  commits: string[] | null
  migrations: string[]
  changes: number
  ci: string
}

type Held = {
  command: string
  risk: Risk
  cwd: string
  where: 'pane' | 'band'
  ship: Ship | null
  decision: 'run' | 'cancel' | null
}

// The call being held, or null. One at a time: a second risky call waits for the first.
let held: Held | null = null

/** Runs a command, answering its trimmed stdout and stderr, or null when it fails. */
const run = async ($: EngineInterface, argv: string[], cwd: string, timeoutMs = 15_000) => {
  try {
    const { exitCode, stdout, stderr } = await $.process.run(argv, { cwd, timeoutMs })
    return exitCode === 0 ? `${stdout}\n${stderr}`.trim() : null
  } catch {
    return null
  }
}

/** Works out what a kamal deploy from `cwd` would ship. */
const measureShip = async ($: EngineInterface, risk: Extract<Risk, { kind: 'ship' }>, cwd: string): Promise<Ship> => {
  const [config, version, head, full, branch, status] = await Promise.all([
    $.fs.read(`${cwd}/config/deploy.yml`).catch(() => ''),
    run($, [risk.kamal, 'app', 'version'], cwd, 30_000),
    run($, ['git', 'rev-parse', '--short', 'HEAD'], cwd),
    run($, ['git', 'rev-parse', 'HEAD'], cwd),
    run($, ['git', 'rev-parse', '--abbrev-ref', 'HEAD'], cwd),
    run($, ['git', 'status', '--porcelain'], cwd),
  ])
  const live = version === null ? null : parseLiveSha(version)
  const [log, added, runs] = await Promise.all([
    live === null ? null : run($, ['git', 'log', '--oneline', '--no-decorate', `${live}..HEAD`], cwd),
    live === null ? null : run($, ['git', 'diff', '--name-only', '--diff-filter=A', `${live}..HEAD`], cwd),
    full === null ? null : run($, ['gh', 'run', 'list', '--commit', full, '--json', 'status,conclusion'], cwd),
  ])

  return {
    host: parseHost(config) ?? 'production',
    live,
    head: head ?? 'HEAD',
    branch: branch ?? 'HEAD',
    commits: log === null ? null : log.split('\n').filter(Boolean),
    migrations: added === null ? [] : migrationNames(added),
    changes: status === null ? 0 : status.split('\n').filter(Boolean).length,
    ci: ciSummary(runs, head ?? 'HEAD'),
  }
}

/** The line under the title saying what ships, for a measured deploy. */
const shipsLine = (ship: Ship) => {
  if (ship.commits === null) return `Ships ${ship.branch} ${ship.head}, live version unknown`
  if (ship.commits.length === 0) return `Nothing new: live is ${ship.branch} ${ship.head}`
  const count = `${ship.commits.length} commit${ship.commits.length === 1 ? '' : 's'}`
  return `Ships ${count}, live ${ship.live} to ${ship.branch} ${ship.head}`
}

const why = { cancel: 'the user pressed Cancel', timeout: 'no answer within 10 minutes', interrupted: 'the turn was interrupted' }

export const register: Register = on => {
  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const risk = classify(e.command)
    if (risk === null) return next(e)

    while (held !== null) {
      if (next.signal.aborted) return { deny: `prod-guard held this command: ${why.interrupted}. Do not retry it unless the user asks you to.` }
      await $.process.run(['sleep', POLL_SECONDS], { timeoutMs: 5_000 })
    }
    const mine: Held = { command: e.command, risk, cwd: await $.session.cwd(), where: 'pane', ship: null, decision: null }
    held = mine

    let isPlaced = false
    let outcome: keyof typeof why | 'run' = 'cancel'
    try {
      const opened = await $.ui.open({ id: PANE, title: 'Production', focus: true, closeOnEscape: true, holdToasts: true, rows: 18 })
      isPlaced = opened.isPlaced
      mine.where = isPlaced ? 'pane' : 'band'
      $.ui.invalidate('ui.render')

      if (risk.kind === 'ship') {
        void measureShip($, risk, mine.cwd)
          .then(ship => {
            mine.ship = ship
            $.ui.invalidate('ui.render')
          })
          .catch(() => undefined)
      }

      const startedAt = await $.clock.now()
      while (mine.decision === null && !next.signal.aborted && (await $.clock.now()) - startedAt < HOLD_LIMIT_MS) {
        await $.process.run(['sleep', POLL_SECONDS], { timeoutMs: 5_000 })
      }
      outcome = mine.decision ?? (next.signal.aborted ? 'interrupted' : 'timeout')
    } finally {
      if (held === mine) held = null
      if (isPlaced) await $.ui.close({ id: PANE }).catch(() => undefined)
      $.ui.invalidate('ui.render')
    }

    if (outcome === 'run') return next(e)
    return { deny: `prod-guard held this command and did not run it: ${why[outcome]}. Do not retry it unless the user asks you to.` }
  }).catch(() => ({ deny: 'prod-guard could not hold this production command, so it did not run. Ask the user to run it themselves.' }))

  on('ui.close', async ($, e, next) => {
    if (e.id === PANE && e.origin.kind === 'person' && held !== null && held.decision === null) held.decision = 'cancel'
    return next(e)
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, ($, e, next) =>
    held === null ? next(e) : draw($, e, held, e.props.bodyColumns),
  )

  on('ui.render', { component: 'AbovePrompt' }, ($, e, next) =>
    held === null || held.where !== 'band' ? next(e) : draw($, e, held, e.props.bodyColumns),
  )
}

/** The dialog: what is held, what it would ship, and the two buttons. */
const draw = ($: EngineInterface, e: Parameters<EngineInterface['ui']['resolve']>[0], state: Held, columns: number) => {
  const { Box, Text, Button } = $.ui.resolve(e)
  const rule = '─'.repeat(Math.max(10, Math.min(columns, 52)))
  // The buttons answer the call this dialog was drawn for, never whichever one is held later.
  const decide = (choice: 'run' | 'cancel') => () => {
    if (state.decision === null) state.decision = choice
  }
  const { ship } = state
  const host = state.risk.kind === 'ship' ? ` to ${ship?.host ?? 'production'}` : ''

  return (
    <Box flexDirection="column">
      <Text>
        <Text color="warning" bold>■ HELD </Text>
        <Text bold>{state.risk.label}</Text>
        <Text bold>{host}</Text>
      </Text>
      <Text dimColor>{rule}</Text>
      {state.risk.kind === 'run' && <Text wrap="truncate-end">{state.command}</Text>}
      {state.risk.kind === 'run' && <Text dimColor>in {state.cwd}</Text>}
      {state.risk.kind === 'ship' && ship === null && <Text dimColor>Checking what this ships...</Text>}
      {ship !== null && <Text dimColor>{shipsLine(ship)}</Text>}
      {ship?.commits?.slice(0, COMMITS_SHOWN).map(line => (
        <Text key={`c-${line.slice(0, 12)}`} wrap="truncate-end">  {line}</Text>
      ))}
      {ship?.commits && ship.commits.length > COMMITS_SHOWN && (
        <Text dimColor>  + {ship.commits.length - COMMITS_SHOWN} more</Text>
      )}
      {ship !== null && ship.migrations.length > 0 && <Text> </Text>}
      {ship !== null && ship.migrations.length > 0 && <Text color="warning">Migrations: {ship.migrations.length}</Text>}
      {ship?.migrations.map(name => <Text key={`m-${name}`}>  {name}</Text>)}
      {ship !== null && <Text> </Text>}
      {ship !== null && (
        <Text>
          {ship.changes === 0 ? (
            <Text dimColor>Working tree clean</Text>
          ) : (
            <Text color="warning">{ship.changes} uncommitted changes will not ship</Text>
          )}
          <Text dimColor> · {ship.ci}</Text>
        </Text>
      )}
      <Text dimColor>{rule}</Text>
      <Box gap={4}>
        <Button key="run" label={state.risk.kind === 'ship' ? 'Deploy' : 'Run'} hotkey="1" plain onPress={decide('run')} />
        <Button key="cancel" label="Cancel" hotkey="2" plain autoFocus onPress={decide('cancel')} />
      </Box>
      <Text dimColor>Cancel has focus. Esc cancels.</Text>
    </Box>
  )
}
