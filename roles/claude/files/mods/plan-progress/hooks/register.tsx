import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Plan, Step, Task } from '../types'
import { parseSteps } from './parse'

const PANE = 'plan'
const plan = atom({ plugin: 'plan-progress', key: 'plan' } as const, null)
const tasks = atom({ plugin: 'plan-progress', key: 'tasks' } as const, [])

const REFRESHES_ON = /\b(git\s+(commit|checkout|switch|rebase|merge)|gh\s+pr)\b/

/** Runs a command in the session's directory, answering its trimmed stdout or null on failure. */
const run = async ($: EngineInterface, argv: string[]) => {
  try {
    const { exitCode, stdout } = await $.process.run(argv, { timeoutMs: 10_000 })
    return exitCode === 0 ? stdout.trim() : null
  } catch {
    return null
  }
}

/** Rereads the branch, its plan.md and its PR into state. */
const refresh = async ($: EngineInterface) => {
  const [root, branch] = await Promise.all([
    run($, ['git', 'rev-parse', '--show-toplevel']),
    run($, ['git', 'rev-parse', '--abbrev-ref', 'HEAD']),
  ])
  if (root === null || branch === null) {
    await update($, plan, () => null)
    return
  }

  const path = `.scratch/${branch}/plan.md`
  const [markdown, pr] = await Promise.all([
    $.fs.read(`${root}/${path}`).catch(() => null),
    run($, ['gh', 'pr', 'view', '--json', 'number,state', '--jq', '"PR #\\(.number) \\(.state | ascii_downcase)"']),
  ])
  const next: Plan = {
    branch,
    path,
    steps: markdown === null ? null : parseSteps(markdown),
    pr,
  }
  await update($, plan, () => next)
}

const plural = (count: number, word: string) => `${count} ${word}${count === 1 ? '' : 's'}`

/** One line for the /progress command's transcript row. */
const summary = (current: Plan | null) => {
  if (current === null) return 'Not in a git repository.'
  if (current.steps === null) return `No plan at ${current.path}.`
  const done = current.steps.filter(step => step.isDone).length
  return `${done} of ${current.steps.length} steps done on ${current.branch}.`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'progress', description: 'Show what is left in this branch plan' })
    await refresh($)
    const current = await read($, plan)
    if (current?.steps) void $.ui.open({ id: PANE, title: 'Plan' })

    return next(e)
  })

  on('session.end', async ($, e, next) => {
    await update($, tasks, () => [])
    return next(e)
  })

  on('command.run', { command: 'progress' }, async $ => {
    await refresh($)
    await $.ui.open({ id: PANE, title: 'Plan' })

    return { text: summary(await read($, plan)) }
  })

  on('tool.call', { tool: 'TaskCreate' }, async ($, e, next) => {
    const ran = await next(e)
    if (ran.deny === undefined && !ran.isError) {
      const task: Task = { id: ran.result.task.id, subject: ran.result.task.subject, status: 'pending' }
      await update($, tasks, list => [...list, task])
    }

    return ran
  })

  on('tool.call', { tool: 'TaskUpdate' }, async ($, e, next) => {
    const ran = await next(e)
    if (ran.deny === undefined && !ran.isError) {
      const { taskId, subject, status } = e
      await update($, tasks, list =>
        status === 'deleted'
          ? list.filter(task => task.id !== taskId)
          : list.map(task =>
              task.id === taskId
                ? { ...task, subject: subject ?? task.subject, status: status ?? task.status }
                : task,
            ),
      )
    }

    return ran
  })

  on('tool.call', { tool: ['Edit', 'Write'] }, async ($, e, next) => {
    const ran = await next(e)
    if (/\/\.scratch\/.+\/plan\.md$/.test(e.file_path)) await refresh($)

    return ran
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const ran = await next(e)
    if (REFRESHES_ON.test(e.command)) await refresh($)

    return ran
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const current = await read($, plan)
    const live = (await read($, tasks)).filter(task => task.status !== 'completed')

    if (current === null || current.steps === null) {
      return <Text dimColor>{summary(current)}</Text>
    }

    const left = current.steps.filter(step => !step.isDone)
    const done = current.steps.filter(step => step.isDone)
    const commits = done.reduce((sum, step) => sum + step.shas.length, 0)
    const row = (step: Step, isNow: boolean) =>
      isNow ? (
        <Text key={`step-${step.n}`} color="suggestion">
          ▸ {step.n} {step.text}  now
        </Text>
      ) : (
        <Text key={`step-${step.n}`}>
          ○ {step.n} {step.text}
        </Text>
      )

    return (
      <Box flexDirection="column">
        <Text>
          <Text bold>Left</Text>
          <Text dimColor>  {plural(left.length, 'step')}</Text>
        </Text>
        {left.length === 0 && <Text dimColor>All steps done.</Text>}
        {left.map((step, index) => (
          <Box key={`left-${step.n}`} flexDirection="column">
            {row(step, index === 0)}
            {index === 0 &&
              live.map(task => (
                <Text key={`task-${task.id}`} color={task.status === 'in_progress' ? 'suggestion' : undefined}>
                  {'    '}
                  {task.status === 'in_progress' ? '▸' : '○'} {task.subject}
                </Text>
              ))}
          </Box>
        ))}
        <Text> </Text>
        <Text>
          <Text bold>Done</Text>
          <Text dimColor>  {plural(done.length, 'step')}{commits > 0 ? `, ${plural(commits, 'commit')}` : ''}</Text>
        </Text>
        {done.map(step => (
          <Text key={`done-${step.n}`} dimColor>
            ✓ {step.n} {step.text}{step.shas.length > 0 ? `  ${plural(step.shas.length, 'commit')}` : ''}
          </Text>
        ))}
        <Text> </Text>
        <Text dimColor>ship: {current.pr ?? 'no PR yet'}</Text>
      </Box>
    )
  })
}
