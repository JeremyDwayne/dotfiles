export type Worktree = {
  path: string
  /** Branch name, or the short SHA when detached. */
  branch: string
  /** The tool that made it, from its folder: claude, codex, cursor, t3 or git. */
  from: string
  age: string
  committedAt: number
  isMerged: boolean
  changes: number
  isCurrent: boolean
  /** The folder changed in the last 15 minutes, so another session may have just made it. */
  isRecent: boolean
}

export type Scan = { repo: string; root: string; gone: number; worktrees: Worktree[] }

declare module 'claude-code' {
  interface PluginState {
    worktrees: { scan: Scan | null; busy: string | null }
  }
}
