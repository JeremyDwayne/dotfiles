import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

const edited = atom({ plugin: 'verify-status', key: 'edited' } as const, [])

const TEST_RUN =
  /\b(pytest|vitest|jest|rspec|go test|cargo test|mix test|(pnpm|npm|yarn|bun)( run)? test|manage\.py test|rails test|make (test|check))\b/
// A pipe like `pytest | tail` exits 0 on failure, so the output is read too.
const FAILED = /\b[1-9]\d* (failed|failures?|errors?)\b|^FAIL(ED)?\b/m

/** Where statusline.sh reads this session's untested edit count. */
const segmentPath = async ($: EngineInterface) =>
  `${await $.env.get('HOME')}/.claude/state/verify-status/${await $.session.id()}`

/** Writes the count of untested edits for the status line, empty when there are none. */
const publish = async ($: EngineInterface) => {
  const files = await read($, edited)
  await $.fs.write(await segmentPath($), files.length > 0 ? String(files.length) : '')
}

export const register: Register = on => {
  on('tool.call', { tool: ['Edit', 'Write', 'NotebookEdit'] }, async ($, e, next) => {
    const ran = await next(e)
    const path = 'file_path' in e ? e.file_path : e.notebook_path
    if (ran.deny === undefined && !ran.isError && !path.includes('/.scratch/')) {
      await update($, edited, files => (files.includes(path) ? files : [...files, path]))
      await publish($)
    }

    return ran
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const ran = await next(e)
    const hasPassed =
      ran.deny === undefined &&
      !ran.isError &&
      !e.run_in_background &&
      !FAILED.test(`${ran.result.stdout}\n${ran.result.stderr}`)
    if (hasPassed && TEST_RUN.test(e.command) && (await read($, edited)).length > 0) {
      await update($, edited, () => [])
      await publish($)
    }

    return ran
  })

  on('session.end', async ($, e, next) => {
    await update($, edited, () => [])
    await $.process.run(['rm', '-f', await segmentPath($)]).catch(() => undefined)

    return next(e)
  })
}
