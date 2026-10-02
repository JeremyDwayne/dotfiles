import type { Step } from '../types'

const STEP = /^\s*(\d+)\.\s+(?:\[([ xX])\]\s+)?(.+?)\s*$/
const SHAS = /\s*\(([0-9a-f]{7,40}(?:\s*,\s*[0-9a-f]{7,40})*)\)$/

/** Reads the numbered steps under the plan's "## Order of work" heading. */
export const parseSteps = (markdown: string): Step[] => {
  const section = markdown.split(/^## /m).find(part => part.startsWith('Order of work'))

  return (section ?? '').split('\n').flatMap(line => {
    const match = STEP.exec(line)
    if (!match) return []
    const [, n = '0', box, rest = ''] = match
    const shas = SHAS.exec(rest)?.[1]?.split(/\s*,\s*/) ?? []

    return [{ n: Number(n), text: rest.replace(SHAS, ''), isDone: box === 'x' || box === 'X', shas }]
  })
}
