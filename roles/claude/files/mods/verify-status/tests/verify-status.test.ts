import type { On } from 'claude-code'
import { describe, expect, mock, test } from 'claude-code/testing'

const SEGMENT = '/home/j/.claude/state/verify-status/s1'

/** A session whose tools all succeed, except Bash commands that mention `fail`. */
const session = (on: On) => {
  const writes: string[] = []
  mock.env(on, { HOME: '/home/j' })
  on('session.id', () => ({ value: 's1' }))
  on('fs.write', ($, e) => {
    if (e.path === SEGMENT) writes.push(e.text)
    return { value: undefined }
  })
  on('tool.call', ($, e) =>
    e.tool === 'Bash' && String(Reflect.get(e, 'command')).includes('fail')
      ? { result: { stdout: '', stderr: 'failed' }, isError: true }
      : { result: {} },
  )
  return writes
}

const edit = (file_path: string) => ({ tool: 'Edit', file_path, old_string: 'a', new_string: 'b' }) as const

describe('verify-status', () => {
  test('counts each edited file once, skipping the plan', async ($, on) => {
    const writes = session(on)

    await $.tool.call(edit('/work/a.py'))
    await $.tool.call(edit('/work/b.py'))
    await $.tool.call(edit('/work/a.py'))
    await $.tool.call(edit('/work/.scratch/feat/plan.md'))

    expect(writes).toEqual(['1', '2', '2'])
  })

  test('a passing test run clears the count, a failing one keeps it', async ($, on) => {
    const writes = session(on)

    await $.tool.call(edit('/work/a.py'))
    await $.tool.call({ tool: 'Bash', command: 'uv run pytest bom/ && echo fail' })
    await $.tool.call({ tool: 'Bash', command: 'uv run pytest bom/' })

    expect(writes).toEqual(['1', ''])
  })
})
