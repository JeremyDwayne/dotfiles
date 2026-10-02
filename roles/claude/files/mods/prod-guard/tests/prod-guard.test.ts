import type { On, RenderInput } from 'claude-code'
import type { Engine } from 'claude-code/testing'
import { describe, expect, mock, test } from 'claude-code/testing'

import { classify } from '../hooks/classify'

const PANE: RenderInput<'Pane'> = {
  component: 'Pane',
  surface: 'terminal',
  requestId: 'prod-guard',
  viewport: { columns: 160, rows: 40 },
  props: { title: 'Production', isFocused: true, bodyColumns: 60, placement: 'dock', scroll: { offset: 0, bodyRows: 30 }, view: {} },
}

const LOG = ['a84bafa fix(rfi): autosave keeps attachments', 'b2', 'c3', 'd4', 'e5'].join('\n')

const GIT: [RegExp, string][] = [
  [/app version/, '  INFO [x] Running docker ps\nApp Host: 10.0.0.1\n3f0c9e1aa2b3c4d5\n'],
  [/rev-parse --short HEAD/, 'a84bafa\n'],
  [/rev-parse HEAD/, 'a84bafa000000000000000000000000000000000\n'],
  [/--abbrev-ref/, 'main\n'],
  [/status --porcelain/, ''],
  [/git log/, LOG],
  [/git diff/, 'submittals/migrations/0142_bom_unmatched_index.py\nsubmittals/views.py\n'],
  [/gh run list/, '[{"status":"completed","conclusion":"success"}]'],
  [/^sleep/, ''],
]

const textOf = (tree: unknown, isInText = false): string => {
  if (typeof tree === 'string' || typeof tree === 'number') return String(tree)
  if (Array.isArray(tree)) return tree.map(child => textOf(child, isInText)).join('')
  if (typeof tree !== 'object' || tree === null) return ''
  const label: unknown = Reflect.get(Reflect.get(tree, 'props') ?? {}, 'label')
  const isText = Reflect.get(tree, 'type') === 'Text'
  const inner = `${typeof label === 'string' ? `[${label}]` : ''}${textOf(Reflect.get(tree, 'children') ?? [], isInText || isText)}`
  return isText && !isInText ? `${inner}\n` : inner
}

/** A repo in /work that kamal deploys to submittalkit.com; records the commands that really ran. */
const repo = (on: On) => {
  const ran: string[] = []
  mock.clock(on)
  on('session.cwd', () => ({ value: '/work' }))
  on('process.run', ($, e) => {
    const line = e.argv.join(' ')
    const stdout = GIT.find(([pattern]) => pattern.test(line))?.[1]
    return { value: { exitCode: stdout === undefined ? 1 : 0, stdout: stdout ?? '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }
  })
  on('fs.read', () => ({ value: 'proxy:\n  ssl: true\n  host: submittalkit.com\n' }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('ui.close', () => ({ value: undefined }))
  on('ui.invalidate', () => ({ value: undefined }))
  on('ui.render', () => ({ type: 'Text', children: [''] }))
  on('tool.call', ($, e) => {
    ran.push(String(Reflect.get(e, 'command')))
    return { result: { stdout: 'deployed', stderr: '' } }
  })
  return ran
}

/** Draws the dialog until `text` shows in it. */
const drawnWith = async ($: Engine, text: string) => {
  for (let tries = 0; tries < 200; tries += 1) {
    const drawn = textOf(await $.ui.render(PANE))
    if (drawn.includes(text)) return drawn
  }
  throw new Error(`never drew ${text}`)
}

describe('prod-guard', () => {
  test('holds deploys, prod psql and destructive make targets, nothing else', () => {
    expect(classify('kamal deploy')).toEqual({ kind: 'ship', label: 'kamal deploy', kamal: 'kamal' })
    expect(classify('cd app && bin/kamal redeploy -d prod')).toEqual({ kind: 'ship', label: 'kamal redeploy', kamal: 'bin/kamal' })
    expect(classify(`ssh deploy@box "kamal deploy"`)?.label).toBe('kamal deploy')
    expect(classify('psql "$(bin/prod-secret DATABASE_URL)" -c "select 1"')?.label).toBe('psql on production')
    expect(classify('make db-reset')?.label).toBe('make db-reset')
    expect(classify('kamal app logs')).toBeNull()
    expect(classify('psql postgres://localhost/dev')).toBeNull()
    expect(classify('make test')).toBeNull()
  })

  test('Cancel refuses the deploy and it never runs', async ($, on) => {
    const ran = repo(on)

    const call = $.tool.call({ tool: 'Bash', command: 'kamal deploy' })
    await drawnWith($, 'HELD')
    await $.ui.press({ plugin: 'prod-guard', key: 'cancel' })
    const result = await call

    expect(result.deny).toContain('the user pressed Cancel')
    expect(ran).toEqual([])
  })

  test('shows what the deploy ships, and Deploy runs it', async ($, on) => {
    const ran = repo(on)

    const call = $.tool.call({ tool: 'Bash', command: 'kamal deploy' })
    const drawn = await drawnWith($, 'CI green')
    await $.ui.press({ plugin: 'prod-guard', key: 'run' })
    await call

    expect(drawn).toBe(
      [
        '■ HELD kamal deploy to submittalkit.com',
        '─'.repeat(52),
        'Ships 5 commits, live 3f0c9e1 to main a84bafa',
        '  a84bafa fix(rfi): autosave keeps attachments',
        '  b2',
        '  c3',
        '  + 2 more',
        ' ',
        'Migrations: 1',
        '  0142_bom_unmatched_index',
        ' ',
        'Working tree clean · CI green on a84bafa',
        '─'.repeat(52),
        '[Deploy][Cancel]Cancel has focus. Esc cancels.',
        '',
      ].join('\n'),
    )
    expect(ran).toEqual(['kamal deploy'])
  })
})
