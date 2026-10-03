/** Absolute paths edited since the last passing test run. */
export type Edited = string[]

declare module 'claude-code' {
  interface PluginState {
    'verify-status': { edited: Edited }
  }
}
