export type Listed = { path: string; head: string; branch: string; isGone: boolean }

/** Reads `git worktree list --porcelain`, main worktree first. */
export const parseWorktrees = (porcelain: string): Listed[] =>
  porcelain
    .trim()
    .split(/\n\s*\n/)
    .map(block => {
      const field = (name: string) =>
        block
          .split('\n')
          .find(line => line === name || line.startsWith(`${name} `))
          ?.slice(name.length + 1)
      const head = field('HEAD') ?? ''
      return {
        path: field('worktree') ?? '',
        head,
        branch: field('branch')?.replace('refs/heads/', '') ?? head.slice(0, 7),
        isGone: field('prunable') !== undefined,
      }
    })

/** Which tool made a worktree, from where its folder lives. */
export const fromOf = (path: string) =>
  path.includes('/.claude/worktrees/') ? 'claude'
  : path.includes('/.codex/') ? 'codex'
  : path.includes('/.cursor/') ? 'cursor'
  : path.includes('/.t3/') ? 't3'
  : 'git'

/** "3 months ago" or "1 year, 2 months ago" as "3 months" or "1 year". */
export const shortAge = (relative: string) => relative.replace(/ ago$/, '').split(',')[0] ?? relative
