# TypeScript, React, Vite, TanStack, Zustand traps

Read this when the repo has TypeScript or React. Each item is a thing that has actually
shipped and broken; check the change against it.

## TypeScript

- Type holes: new `any`, `as` casts (worst: `as unknown as T`), non-null `!`,
  `@ts-ignore` / `@ts-expect-error`, lint disable comments. Each is a place the checker
  stopped looking. Trace the value it hides, and compare the disable count with the base.
- Data from outside the program typed by assertion: `(await res.json()) as T`,
  `JSON.parse`, `localStorage`, URL search params, `postMessage`, SSE or websocket
  payloads. Without a schema (ArkType, zod, valibot) at that boundary the type is a guess.
- Generated types (OpenAPI, JSON schema, DB types, `routeTree.gen.ts`): regenerated after
  their source changed, never hand-edited. A stale generated file lets `tsc` pass against
  a contract the server no longer keeps.
- Exhaustiveness: a union or enum gained a member. Every `switch` over it needs a
  `satisfies never` or `assertNever` default, and every lookup should be a
  `Record<Union, X>`. A `default:` that quietly handles the new member is a finding.
- Index access: without `noUncheckedIndexedAccess`, `arr[0]` and `map[key]` are typed as
  present. Check `tsconfig` before trusting either.
- `||` vs `??` on values that can be `0`, `""`, or `false`. `{count && <X />}` renders `0`.
- `{...obj, field: undefined}` overwrites; `?:` and `| undefined` differ under
  `exactOptionalPropertyTypes`.
- Coverage of the checker: a new file or folder outside every tsconfig `include` is not
  type-checked. Repos with several tsconfigs (app, node, worker) need each one run.
- Dates: `new Date("2026-10-09")` is UTC midnight, the previous day west of UTC;
  `toISOString().slice(0, 10)` is the UTC date; months are 0-based. A "today" computed
  once at mount goes stale on a tab left open overnight.
- Numbers: `Number("")` is `0`, `parseInt("08x")` is `8`, floats for money.
- Import cycles: module-level code that reads an import still in its temporal dead zone
  works in one import order and throws in another.

## React rendering and state

- Props copied into `useState` and reset by an effect or on every parent render: a local
  edit snaps back while its own save is in flight, because the save re-renders the
  parent. Look for `useEffect(() => setX(prop), [prop])`.
- Keys: index keys on lists that reorder, insert, or delete move state and focus to the
  wrong row. A key that changes every render remounts the subtree and drops input.
- Effects: missing dependencies (stale closure); object, array, or function dependencies
  rebuilt each render (runs every render, or loops); no cleanup for listeners, timers,
  subscriptions, `AbortController`; an async result applied after a newer request
  started (out-of-order responses). StrictMode runs effects twice in dev to expose this.
- Work that belongs in an event handler (POST, analytics, navigation) run from an effect
  on state change fires again on remount or on a later re-render.
- Re-render cost: a context value or hook high in the tree that changes often (a clock,
  a new object per render) re-renders every consumer. Store the coarsest value the UI
  shows: a date string that changes daily, not a `Date` that changes every minute.
- Controlled inputs whose `value` can become `undefined` flip to uncontrolled.
- Suspense and error boundaries: a new `lazy` component or `useSuspenseQuery` with no
  boundary above it; a boundary that never resets on navigation.
- Raw HTML: `dangerouslySetInnerHTML`, rich-text or markdown HTML rendered without
  sanitizing, `href` or `src` built from user data (`javascript:` URLs).

## Server state (React Query)

- Query keys: a key missing a variable the `queryFn` reads shows one record's data under
  another's id. Two hooks sharing a key with different data shapes corrupt each other.
  A key built by hand where the repo has a key factory or `queryOptions`.
- Invalidation: after a mutation, does every list, detail, count, and other open tab
  that shows the row update? Invalidating nothing, the wrong prefix, or the whole cache
  are all findings.
- Deletes: invalidating or refetching the deleted record's own detail query produces a
  404 and an error toast. Close the open detail or drawer and `removeQueries` first.
- Optimistic updates: `onMutate` must `cancelQueries` for the key, snapshot, roll back in
  `onError`, and invalidate in `onSettled`. Without the cancel, a refetch that lands mid
  mutation overwrites the optimistic value and the UI flickers back.
- Retries: a mutation is replayable only if it is idempotent. A retry or Retry button on
  a POST whose response was lost can create the row twice. Query `retry` on 401, 403,
  or 404 delays the error state for nothing.
- v5 status: `isPending` stays true forever for a query with `enabled: false`;
  `placeholderData: keepPreviousData` shows the previous id's data under the new header.
- `staleTime` and `refetchOnWindowFocus` changes: refetch storms on focus, or data that
  never refreshes after another tab writes.
- Error toasts raised by both a global `QueryCache`/`MutationCache` `onError` and a local
  handler show twice.

## Live updates (SSE, websockets)

- Every new server event type has a client handler, or other open tabs keep showing the
  old rows.
- An event caused by this tab's own write is skipped, not refetched. Otherwise a delete
  reads back its own deleted row.
- A reconnect after a long hidden tab replays a burst: coalesce into one refresh instead
  of one refetch per event.
- Subscriptions opened in effects close on unmount and on dependency change.

## Routing (TanStack Router and Start)

- `routeTree.gen.ts` regenerated and committed with the route change.
- Search params are user input: every param a `Link` or `navigate` sets is in the route's
  `validateSearch` schema with a default. A param missing from the schema is dropped.
- Loaders: `loaderDeps` lists every search param the loader reads, or it serves stale
  data. A loader's `ensureQueryData` uses the same key as the component's `useQuery`, or
  the prefetch is wasted and the page fetches twice.
- Guards: a new route placed outside the layout whose `beforeLoad` checks auth is
  public. Client guards are UX; the API or server function enforces access.
- Typed `to` and `params` instead of string paths; `<a href>` to an internal route does
  a full reload.
- Start server functions: input validated by the function's validator, session and
  tenant checked inside the handler, nothing trusted from the client. Server-only
  modules (secrets, DB clients) never imported from client code.

## Client state (Zustand)

- A selector returning a new object or array each call (`s => ({ a: s.a, b: s.b })`)
  re-renders every time, and in v5 can loop. Use `useShallow` or select primitives.
- Server data copied into a store goes stale next to React Query's copy. Keep server
  state in the query cache.
- `persist`: a shape change needs a `version` bump and `migrate`; old tabs and old
  localStorage rehydrate into new code.
- Module-level stores share state across tests unless reset.

## Accessibility and focus

- A clickable `div` or `tr` with `onClick` is unreachable from the keyboard. Use a
  `button` or link.
- Delete, close, collapse, and reorder remove or move the focused element, and focus
  falls to `body`. Check where focus lands after each.
- Dialogs: focus moves in, Escape closes once, focus returns to the opener.
- Status that a sighted user sees (saved, failed, undone) is announced through a
  `role="status"` region, once, not again on re-render.
- `aria-controls`, `aria-describedby`, and `htmlFor` point at ids that still exist
  (`useId`, not hard-coded ids in repeated components).
- Toast actions such as Undo dismiss their toast, so they cannot run twice.

## Vite, build, and deploy

- `VITE_*` variables are inlined into the public bundle. A secret behind that prefix is
  a BLOCKER. A new variable is typed in `env.d.ts` and set in every environment and CI.
- `import.meta.env.DEV` or `MODE` branches that ship debug code, mocks, or skipped auth.
- Old tabs: after a deploy, open tabs run the old bundle against the new API and request
  hashed chunks that no longer exist. Is there a `vite:preloadError` or chunk-failure
  reload? Is an API field removed while old tabs still read it?
- Cache headers: `index.html` must not be long-cached; hashed assets should be.
- A heavy library (PDF, editor, charts) imported from the entry instead of a lazy route
  or dynamic `import()`. Check the repo's size budget if it has one.
- Dev proxy routes in `vite.config.ts` with no matching production route (CDN, Worker,
  reverse proxy): works locally, 404s in prod.
- Build output committed: `dist/`, `*.tsbuildinfo`, `.js` emitted next to `.ts`.
- `package.json` changed without the lockfile, or the reverse.

## Edge workers (Cloudflare)

- Worker code has no DOM and no Node globals unless `nodejs_compat` is set. Code shared
  between the worker and the browser uses neither.
- Bindings, vars, and secrets referenced in code exist in `wrangler` config for every
  environment.
- Responses carrying user data cached at the edge, or a cache key missing the session.

## Auth (Clerk, better-auth)

- `SignedIn`, `useAuth`, or a hidden button is UX only. Every API route and server
  function checks the session and the org itself.
- An `orgId` or `userId` sent from the client and trusted by the server is an IDOR.
- Redirect and callback URLs built from params need an allowlist; `trustedOrigins` and
  cookie `sameSite` / `secure` changes get read closely.

## Tests (Vitest, Testing Library)

- `userEvent` calls not awaited, or `getBy` where `findBy` was needed: assertions run
  before the update and pass against the old behavior.
- `vi.mock` of the module under test, or of the API client so deeply that the test
  checks the mock.
- Fake timers, `vi.spyOn`, and global stubs (`matchMedia`, `ResizeObserver`) not
  restored, leaking into later tests.
- Snapshots regenerated wholesale in the PR. Read the snapshot diff as code.
- Queries by role and accessible name catch a11y regressions; test ids do not.
