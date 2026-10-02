/** A held command: `ship` deploys HEAD and gets a report of what ships, `run` shows the command alone. */
export type Risk = { kind: 'ship'; label: string; kamal: string } | { kind: 'run'; label: string }

const SHIP = /(?:^|[\s;&|("'`])((?:[^\s"'`]*\/)?kamal)\s+(deploy|redeploy)\b/
const ROLLBACK = /\bkamal\s+rollback\b/
const PROD = /\bprod(uction)?\b/
const MAKE = /\bmake\b[^|;&]*?\b(prod-db-console|db-destroy|db-drop|db-reset)\b/

/** Names the production risk in a shell command, or null when it has none. */
export const classify = (command: string): Risk | null => {
  const ship = SHIP.exec(command)
  if (ship) return { kind: 'ship', label: `kamal ${ship[2]}`, kamal: ship[1] ?? 'kamal' }
  if (ROLLBACK.test(command)) return { kind: 'run', label: 'kamal rollback' }
  if (/\bpsql\b/.test(command) && PROD.test(command)) return { kind: 'run', label: 'psql on production' }
  const target = MAKE.exec(command)?.[1]
  return target ? { kind: 'run', label: `make ${target}` } : null
}

/** The public host from a Kamal config/deploy.yml, or null. */
export const parseHost = (deployYml: string) => /^\s*host:\s*["']?([^\s"']+)/m.exec(deployYml)?.[1] ?? null

/** The running version from `kamal app version` output: the first line that is only a commit SHA. */
export const parseLiveSha = (output: string) => /^\s*([0-9a-f]{7,40})\s*$/m.exec(output)?.[1]?.slice(0, 7) ?? null

/** Migration names among files a deploy adds (Django and Rails layouts). */
export const migrationNames = (addedFiles: string) =>
  addedFiles
    .split('\n')
    .filter(path => /\/migrations\/\d{4}_\w+\.py$|^db\/migrate\/\d+_\w+\.rb$/.test(path))
    .map(path => (path.split('/').pop() ?? path).replace(/\.(py|rb)$/, ''))

/** One phrase for the GitHub Actions runs on a commit, from `gh run list --json status,conclusion`. */
export const ciSummary = (runsJson: string | null, sha: string) => {
  if (runsJson === null) return 'CI unknown'
  const runs: { status: string; conclusion: string }[] = JSON.parse(runsJson)
  if (runs.length === 0) return `no CI runs on ${sha}`
  if (runs.some(run => run.conclusion === 'failure')) return `CI failed on ${sha}`
  if (runs.some(run => run.status !== 'completed')) return `CI running on ${sha}`
  return `CI green on ${sha}`
}
