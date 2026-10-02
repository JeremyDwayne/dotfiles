import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Scan, Worktree } from '../types'
import { fromOf, parseWorktrees, shortAge } from './parse'

const PANE = 'worktrees'
const scan = atom({ plugin: 'worktrees', key: 'scan' } as const, null)
const busy = atom({ plugin: 'worktrees', key: 'busy' } as const, null)

/** Runs git, answering its exit code and trimmed stdout. */
const git = async ($: EngineInterface, argv: string[], cwd?: string) => {
  try {
    const { exitCode, stdout } = await $.process.run(['git', ...argv], { cwd, timeoutMs: 30_000 })
    return { exitCode, stdout: stdout.trim() }
  } catch {
    return { exitCode: -1, stdout: '' }
  }
}

/** Lists the repo's worktrees with their state; null outside a git repository. */
const scanRepo = async ($: EngineInterface): Promise<Scan | null> => {
  const [list, current, base] = await Promise.all([
    git($, ['worktree', 'list', '--porcelain']),
    git($, ['rev-parse', '--show-toplevel']),
    git($, ['symbolic-ref', '--short', 'refs/remotes/origin/HEAD']),
  ])
  if (list.exitCode !== 0) return null

  const [main, ...linked] = parseWorktrees(list.stdout)
  const into = base.exitCode === 0 ? base.stdout : 'main'
  const live = linked.filter(tree => !tree.isGone)
  const worktrees = await Promise.all(
    live.map(async (tree): Promise<Worktree> => {
      const [status, log, merged] = await Promise.all([
        git($, ['status', '--porcelain'], tree.path),
        git($, ['log', '-1', '--format=%ct %cr'], tree.path),
        git($, ['merge-base', '--is-ancestor', tree.head, into]),
      ])
      const [stamp = '0', ...relative] = log.stdout.split(' ')
      return {
        path: tree.path,
        branch: tree.branch,
        from: fromOf(tree.path),
        age: shortAge(relative.join(' ')),
        committedAt: Number(stamp),
        isMerged: merged.exitCode === 0,
        changes: status.stdout === '' ? 0 : status.stdout.split('\n').length,
        isCurrent: tree.path === current.stdout,
      }
    }),
  )
  const root = main?.path ?? ''

  return { repo: root.split('/').pop() ?? root, root, gone: linked.length - live.length, worktrees }
}

const refresh = async ($: EngineInterface) => {
  const next = await scanRepo($)
  await update($, scan, () => next)
}

/** Removes each merged worktree with no changes, one at a time so git's lock is free. */
const removeClean = async ($: EngineInterface, current: Scan) => {
  const targets = current.worktrees.filter(tree => tree.isMerged && tree.changes === 0 && !tree.isCurrent)
  await update($, busy, () => `Removing ${targets.length} worktrees...`)
  let removed = 0
  for (const tree of targets) {
    if ((await git($, ['worktree', 'remove', tree.path], current.root)).exitCode === 0) removed += 1
  }
  await refresh($)
  await update($, busy, () => null)
  $.ui.toast(`Removed ${removed} of ${targets.length} worktrees`)
}

const prune = async ($: EngineInterface, current: Scan) => {
  await update($, busy, () => 'Pruning...')
  await git($, ['worktree', 'prune'], current.root)
  await refresh($)
  await update($, busy, () => null)
  $.ui.toast(`Pruned ${current.gone} worktrees`)
}

const fit = (text: string, width: number) =>
  text.length <= width ? text.padEnd(width) : `${text.slice(0, width - 1)}…`

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'worktrees', description: 'List, prune and remove this repo worktrees' })
    return next(e)
  })

  on('command.run', { command: 'worktrees' }, async $ => {
    await update($, scan, () => null)
    await $.ui.open({ id: PANE, title: 'Worktrees', focus: true, closeOnEscape: true })
    await refresh($)
    const current = await read($, scan)
    return { text: current === null ? 'Not in a git repository.' : `${current.worktrees.length + current.gone} worktrees in ${current.repo}.` }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const current = await read($, scan)
    const working = await read($, busy)
    if (current === null) return <Text dimColor>Reading worktrees...</Text>

    const open = current.worktrees.filter(tree => !tree.isMerged)
    const merged = current.worktrees.filter(tree => tree.isMerged).sort((a, b) => a.committedAt - b.committedAt)
    const total = current.worktrees.length + current.gone
    const branchWidth = Math.min(28, Math.max(10, e.props.bodyColumns - 26))
    const room = Math.max(4, e.props.scroll.bodyRows - 9)
    const shownOpen = open.slice(0, room)
    const shownMerged = merged.slice(0, Math.max(0, room - shownOpen.length))
    const row = (tree: Worktree) => (
      <Text key={tree.path}>
        {'  '}
        {fit(tree.branch, branchWidth)} <Text dimColor>{fit(tree.from, 7)} {fit(tree.age, 9)}</Text>{' '}
        {tree.isCurrent ? <Text dimColor>this session</Text> : tree.changes > 0 ? <Text color="warning">{tree.changes} changes</Text> : 'clean'}
      </Text>
    )

    return (
      <Box flexDirection="column">
        <Text>
          <Text bold>Worktrees</Text>
          <Text dimColor>  {current.repo} · {total}</Text>
        </Text>
        <Text dimColor>{'─'.repeat(Math.min(54, e.props.bodyColumns))}</Text>
        <Box gap={1}>
          <Text dimColor>○ folder gone     {String(current.gone).padStart(3)}</Text>
          {current.gone > 0 && working === null && <Button key="prune" label="Prune" hotkey="p" plain onPress={() => void prune($, current)} />}
        </Box>
        <Box gap={1}>
          <Text color="suggestion">✓ merged          {String(merged.length).padStart(3)}</Text>
          {merged.some(tree => tree.changes === 0 && !tree.isCurrent) && working === null && (
            <Button key="remove" label="Remove clean ones" hotkey="r" plain onPress={() => void removeClean($, current)} />
          )}
        </Box>
        <Text bold>▸ open            {String(open.length).padStart(3)}</Text>
        {working !== null && <Text dimColor>{working}</Text>}
        <Text> </Text>
        {open.length > 0 && <Text bold>▸ open</Text>}
        {shownOpen.map(row)}
        {merged.length > 0 && (
          <Text>
            <Text color="suggestion">✓ merged</Text>
            <Text dimColor> (oldest first)</Text>
          </Text>
        )}
        {shownMerged.map(row)}
        {shownOpen.length + shownMerged.length < current.worktrees.length && (
          <Text dimColor>  + {current.worktrees.length - shownOpen.length - shownMerged.length} more</Text>
        )}
      </Box>
    )
  })
}
