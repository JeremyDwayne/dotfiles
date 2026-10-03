import type { Register } from 'claude-code'

type Hunk = { oldStart: number; newStart: number; lines: string[] }
type Row = { number: number; marker: ' ' | '−' | '+'; text: string }

const MAX_ROWS = 80
const COLOR = { ' ': undefined, '−': 'warning', '+': 'suggestion' } as const

/** The hunks of an Edit or Write result, or null when it carries none. */
const hunksOf = (output: unknown): Hunk[] | null => {
  const patch: unknown = typeof output === 'object' && output !== null ? Reflect.get(output, 'structuredPatch') : null
  return Array.isArray(patch) && patch.length > 0 ? (patch as Hunk[]) : null
}

/** Numbers each hunk line: removed lines by their old number, the rest by their new one. */
const rowsOf = (hunks: Hunk[]): Row[] =>
  hunks.flatMap(hunk => {
    let before = hunk.oldStart
    let after = hunk.newStart
    return hunk.lines.flatMap((line): Row[] => {
      const text = line.slice(1).replaceAll('\t', '    ').replace(/[\x00-\x1f\x7f]/g, '')
      if (line.startsWith('-')) return [{ number: before++, marker: '−', text }]
      if (line.startsWith('+')) return [{ number: after++, marker: '+', text }]
      if (line.startsWith('\\')) return []
      before++
      return [{ number: after++, marker: ' ', text }]
    })
  })

const plural = (count: number) => `${count} line${count === 1 ? '' : 's'}`

export const register: Register = on => {
  on('ui.render', { component: 'ToolResult' }, ($, e, next) => {
    const hunks = e.props.tool === 'Edit' || e.props.tool === 'Write' ? hunksOf(e.props.output) : null
    const rows = hunks === null ? [] : rowsOf(hunks)
    if (e.props.isErrored || rows.length === 0) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const added = rows.filter(row => row.marker === '+').length
    const removed = rows.filter(row => row.marker === '−').length
    const width = String(Math.max(...rows.map(row => row.number))).length
    const summary = [added > 0 && `Added ${plural(added)}`, removed > 0 && `removed ${plural(removed)}`]
      .filter(Boolean)
      .join(', ')

    return (
      <Box flexDirection="column">
        <Text dimColor>  ⎿  {summary.charAt(0).toUpperCase() + summary.slice(1)}</Text>
        {rows.slice(0, MAX_ROWS).map((row, index) => (
          <Text key={`r${index}`} color={COLOR[row.marker]}>
            <Text dimColor={row.marker === ' '}>     {String(row.number).padStart(width)} {row.marker}</Text> {row.text}
          </Text>
        ))}
        {rows.length > MAX_ROWS && <Text dimColor>     + {plural(rows.length - MAX_ROWS)} more</Text>}
      </Box>
    )
  })
}
