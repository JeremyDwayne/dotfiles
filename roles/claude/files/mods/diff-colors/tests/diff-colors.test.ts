import type { RenderInput } from 'claude-code'
import { describe, expect, test } from 'claude-code/testing'

const result = (tool: string, structuredPatch: unknown[], isErrored = false): RenderInput<'ToolResult'> => ({
  component: 'ToolResult',
  surface: 'terminal',
  requestId: 'toolu_1',
  viewport: { columns: 120, rows: 40 },
  props: { tool_use_id: 'toolu_1', tool, isErrored, output: { filePath: '/work/match.py', structuredPatch } },
})

const HUNK = {
  oldStart: 41,
  oldLines: 3,
  newStart: 41,
  newLines: 5,
  lines: [
    '     rows = parse_rows(sheet)',
    '-    matched = [r for r in rows if r.csi]',
    '+    matched = [r for r in rows if r.csi]',
    '+    unmatched = [r for r in rows if not r.csi]',
    '+    log_unmatched(unmatched)',
    '     return matched',
  ],
}

/** Each outermost Text as one line, with its color in front when it has one. */
const linesOf = (tree: unknown, isInText = false): string => {
  if (typeof tree === 'string') return tree
  if (Array.isArray(tree)) return tree.map(child => linesOf(child, isInText)).join('')
  if (typeof tree !== 'object' || tree === null) return ''
  const isText = Reflect.get(tree, 'type') === 'Text'
  const inner = linesOf(Reflect.get(tree, 'children') ?? [], isInText || isText)
  if (!isText || isInText) return inner
  const color: unknown = Reflect.get(Reflect.get(tree, 'props') ?? {}, 'color')
  return `${typeof color === 'string' ? `<${color}>` : ''}${inner}\n`
}

describe('diff-colors', () => {
  test('draws added lines blue and removed lines orange, each numbered and marked', async $ => {
    expect(linesOf(await $.ui.render(result('Edit', [HUNK])))).toBe(
      [
        '  ⎿  Added 3 lines, removed 1 line',
        '     41       rows = parse_rows(sheet)',
        '<warning>     42 −     matched = [r for r in rows if r.csi]',
        '<suggestion>     42 +     matched = [r for r in rows if r.csi]',
        '<suggestion>     43 +     unmatched = [r for r in rows if not r.csi]',
        '<suggestion>     44 +     log_unmatched(unmatched)',
        '     45       return matched',
        '',
      ].join('\n'),
    )
  })

  test('leaves errors, new files, empty hunks and other tools to the engine', async ($, on) => {
    on('ui.render', () => ({ type: 'Text', children: ['engine'] }))

    for (const input of [result('Edit', [HUNK], true), result('Write', []), result('Bash', [HUNK]), result('Edit', [{ ...HUNK, lines: ['\\ No newline at end of file'] }])]) {
      expect(linesOf(await $.ui.render(input))).toBe('engine\n')
    }
  })
})
