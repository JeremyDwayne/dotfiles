import type { On, RenderInput } from 'claude-code'
import type { Engine } from 'claude-code/testing'
import { describe, expect, mock, test } from 'claude-code/testing'

import { parseWorktrees } from '../hooks/parse'

const PORCELAIN = `worktree /work
HEAD aaaaaaa1
branch refs/heads/main

worktree /w/.codex/old
HEAD bbbbbbb2
branch refs/heads/codex/old

worktree /w/.t3/search
HEAD ccccccc3
branch refs/heads/t3code/search

worktree /w/.claude/worktrees/agent-1
HEAD ddddddd4
detached

worktree /w/.claude/worktrees/agent-2
HEAD fffffff6
detached

worktree /gone/x
HEAD eeeeeee5
branch refs/heads/gone
prunable gitdir file points to non-existent location
`

const PANE: RenderInput<'Pane'> = {
  component: 'Pane',
  surface: 'terminal',
  requestId: 'worktrees',
  viewport: { columns: 160, rows: 40 },
  props: { title: 'Worktrees', isFocused: true, bodyColumns: 60, placement: 'dock', scroll: { offset: 0, bodyRows: 30 }, view: {} },
}

const NOW = 1_800_000_000_000

const COMMAND = { command: 'worktrees', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: true, columns: 160 } } as const

/** Answers git for the worktrees above, the session in agent-1; records every git run as "cwd: argv". */
const repo = (on: On) => {
  const runs: string[] = []
  const answers: [RegExp, string, number?][] = [
    [/worktree list/, PORCELAIN],
    [/--show-toplevel/, '/w/.claude/worktrees/agent-1'],
    [/symbolic-ref/, 'origin/main'],
    [/\/w\/\.t3\/search: git status/, ' M a.py\n M b.py\n?? c.py'],
    [/status --porcelain/, ''],
    [/\/w\/\.codex\/old: git log/, '100 3 months ago'],
    [/\/w\/\.t3\/search: git log/, '300 2 weeks ago'],
    [/agent-1: git log/, '200 6 days ago'],
    [/is-ancestor ccccccc3/, '', 1],
    [/is-ancestor/, ''],
    [/worktree (remove|prune)/, ''],
  ]
  mock.clock(on, { now: NOW })
  on('fs.stat', ($, e) => ({
    value: { kind: 'dir', size: 0, isLink: false, mtimeMs: e.path.endsWith('agent-2') ? NOW - 60_000 : NOW - 86_400_000 },
  }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('ui.invalidate', () => ({ value: undefined }))
  on('ui.toast', () => ({ value: undefined }))
  on('process.run', ($, e) => {
    const line = `${e.init?.cwd ?? ''}: ${e.argv.join(' ')}`
    runs.push(line)
    const [, stdout = '', exitCode = 0] = answers.find(([pattern]) => pattern.test(line)) ?? []
    return { value: { exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }
  })
  return runs
}

const textOf = (tree: unknown, isInText = false): string => {
  if (typeof tree === 'string' || typeof tree === 'number') return String(tree)
  if (Array.isArray(tree)) return tree.map(child => textOf(child, isInText)).join('')
  if (typeof tree !== 'object' || tree === null) return ''
  const label: unknown = Reflect.get(Reflect.get(tree, 'props') ?? {}, 'label')
  const isText = Reflect.get(tree, 'type') === 'Text'
  const inner = `${textOf(Reflect.get(tree, 'children') ?? [], isInText || isText)}${typeof label === 'string' ? `[${label}]` : ''}`
  return isText && !isInText ? `${inner}\n` : inner
}

const opened = async ($: Engine) => {
  await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/w/.claude/worktrees/agent-1' })
  await $.command.run(COMMAND)
}

describe('worktrees', () => {
  test('reads branches, detached heads and gone folders from porcelain', () => {
    expect(parseWorktrees(PORCELAIN).map(({ branch, isGone }) => [branch, isGone])).toEqual([
      ['main', false],
      ['codex/old', false],
      ['t3code/search', false],
      ['ddddddd', false],
      ['fffffff', false],
      ['gone', true],
    ])
  })

  test('groups worktrees by state, open first, merged oldest first', async ($, on) => {
    repo(on)
    await opened($)

    const drawn = textOf(await $.ui.render(PANE))
    expect(drawn).toContain('Worktrees  work · 5')
    expect(drawn).toContain('○ folder gone       1')
    expect(drawn).toContain('✓ merged            3')
    expect(drawn).toContain('▸ open              1')
    expect(drawn.indexOf('t3code/search')).toBeLessThan(drawn.indexOf('codex/old'))
    expect(drawn.indexOf('codex/old')).toBeLessThan(drawn.indexOf('ddddddd'))
    expect(drawn).toMatch(/t3code\/search +t3 +2 weeks +3 changes/)
    expect(drawn).toMatch(/ddddddd +claude +6 days +this session/)
    expect(drawn).toMatch(/fffffff +claude +new, kept/)
  })

  test('removes only merged worktrees with no changes, never the session own or one changed in the last 15 minutes', async ($, on) => {
    const runs = repo(on)
    await opened($)
    await $.ui.render(PANE)

    await $.ui.press({ plugin: 'worktrees', key: 'remove' })
    await $.ui.press({ plugin: 'worktrees', key: 'prune' })

    expect(runs.filter(line => /worktree (remove|prune)/.test(line))).toEqual([
      '/work: git worktree remove /w/.codex/old',
      '/work: git worktree prune',
    ])
  })
})
