import type { On, RenderInput } from 'claude-code'
import { describe, expect, test } from 'claude-code/testing'

import { parseSteps } from '../hooks/parse'

const PLAN = `# Plan: BOM importer

## Files that change
1. not a step

## Order of work
1. [x] Parse vendor column aliases (a1c3f2e)
2. [x] Match rows by CSI section (7be019d, 91d2c0e)
3. [ ] Show unmatched rows in review
4. Bulk-assign spec section

## Risks
- none
`

const PANE: RenderInput<'Pane'> = {
  component: 'Pane',
  surface: 'terminal',
  requestId: 'plan',
  viewport: { columns: 160, rows: 40 },
  props: { title: 'Plan', isFocused: false, bodyColumns: 50, placement: 'dock', scroll: { offset: 0, bodyRows: 30 }, view: {} },
}

/** A drawn tree as lines: each outermost Text is one line. */
const textOf = (tree: unknown, isInText = false): string => {
  if (typeof tree === 'string' || typeof tree === 'number') return String(tree)
  if (Array.isArray(tree)) return tree.map(child => textOf(child, isInText)).join('')
  if (typeof tree !== 'object' || tree === null) return ''
  const isText = Reflect.get(tree, 'type') === 'Text'
  const inner = textOf(Reflect.get(tree, 'children') ?? [], isInText || isText)
  return isText && !isInText ? `${inner}\n` : inner
}

/** A session in /work on branch feat/bom, whose plan.md is `plan` (missing when null). */
const inRepo = (on: On, plan: string | null) => {
  const ok = (stdout: string) => ({ value: { exitCode: 0, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false } })
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('command.register', ($, e) => ({ value: { command: e.name } }))
  on('process.run', ($, e) =>
    e.argv.includes('--show-toplevel') ? ok('/work\n')
    : e.argv.includes('--abbrev-ref') ? ok('feat/bom\n')
    : { value: { exitCode: 1, stdout: '', stderr: 'no pull requests found', isStdoutTruncated: false, isStderrTruncated: false } },
  )
  on('fs.read', ($, e) => (plan !== null && e.path === '/work/.scratch/feat/bom/plan.md' ? { value: plan } : { deny: 'ENOENT' }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('ui.invalidate', () => ({ value: undefined }))
}

describe('plan-progress', () => {
  test('reads only the Order of work steps, with boxes and SHAs', () => {
    expect(parseSteps(PLAN)).toEqual([
      { n: 1, text: 'Parse vendor column aliases', isDone: true, shas: ['a1c3f2e'] },
      { n: 2, text: 'Match rows by CSI section', isDone: true, shas: ['7be019d', '91d2c0e'] },
      { n: 3, text: 'Show unmatched rows in review', isDone: false, shas: [] },
      { n: 4, text: 'Bulk-assign spec section', isDone: false, shas: [] },
    ])
  })

  test('draws what is left first, the live tasks under the current step, then what is done', async ($, on) => {
    inRepo(on, PLAN)
    on('tool.call', { tool: 'TaskCreate' }, ($, e) => ({ result: { task: { id: String(e.subject.length), subject: e.subject } } }))
    on('tool.call', { tool: 'TaskUpdate' }, ($, e) => ({ result: { success: true, taskId: e.taskId, updatedFields: ['status'] } }))

    await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/work' })
    await $.tool.call({ tool: 'TaskCreate', subject: 'add unmatched queryset', description: '' })
    await $.tool.call({ tool: 'TaskCreate', subject: 'review table badge', description: '' })
    await $.tool.call({ tool: 'TaskUpdate', taskId: String('add unmatched queryset'.length), status: 'in_progress' })

    expect(textOf(await $.ui.render(PANE))).toBe(
      [
        'Left  2 steps',
        '▸ 3 Show unmatched rows in review  now',
        '    ▸ add unmatched queryset',
        '    ○ review table badge',
        '○ 4 Bulk-assign spec section',
        ' ',
        'Done  2 steps, 3 commits',
        '✓ 1 Parse vendor column aliases  1 commit',
        '✓ 2 Match rows by CSI section  2 commits',
        ' ',
        'ship: no PR yet',
        '',
      ].join('\n'),
    )
  })

  test('says where the plan should be when the branch has none', async ($, on) => {
    inRepo(on, null)

    await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/work' })
    const ran = await $.command.run({ command: 'progress', args: '', origin: { kind: 'composer' }, presentation: { isFullscreen: true, columns: 160 } })

    expect(ran.text).toBe('No plan at .scratch/feat/bom/plan.md.')
    expect(textOf(await $.ui.render(PANE))).toContain('No plan at .scratch/feat/bom/plan.md.')
  })
})
