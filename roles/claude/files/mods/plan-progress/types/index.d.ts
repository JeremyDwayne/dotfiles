export type Step = { n: number; text: string; isDone: boolean; shas: string[] }

export type Plan = {
  branch: string
  /** Path relative to the repo root, for the empty state. */
  path: string
  /** Null when the branch has no plan.md. */
  steps: Step[] | null
  /** One line about the branch's PR, or null when there is none. */
  pr: string | null
}

export type Task = { id: string; subject: string; status: 'pending' | 'in_progress' | 'completed' }

declare module 'claude-code' {
  interface PluginState {
    'plan-progress': { plan: Plan | null; tasks: Task[] }
  }
}
