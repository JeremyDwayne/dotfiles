# Go, chi, pgx/Postgres, River, Redis and SSE traps

Read this when the repo is Go. Each item is a thing that has actually shipped and
broken; check the change against it.

## Language and errors

- `err` shadowed by `:=` in an inner scope, so the outer `err` the function returns
  stays nil. Check every `if x, err := ...` and every `:=` inside a loop or closure.
- An error dropped: `_ =`, a bare call whose error return is ignored, `defer f.Close()`
  on a file or writer that was written to. The write error surfaces only at Close.
- `==` or a type assertion on an error that is now wrapped. Use `errors.Is` and
  `errors.As`. Wrapping with `%v` instead of `%w` cuts the chain for every caller.
- A typed nil returned as an interface: `var e *MyErr; return e` is not `== nil`. Same
  for any nil pointer stored in an interface and then nil-checked.
- Nil map write panics. Nil slice marshals to JSON `null`, an empty slice to `[]`; the
  client that calls `.map` on it cares which.
- `append` on a sub-slice writes into the caller's backing array. A slice or map handed
  out of a struct is shared, not copied; the caller can now mutate internal state.
- `for _, v := range items` copies each element. Mutating `v` changes nothing; index
  into the slice or range over pointers.
- Map iteration order is random. Output, a test assertion, or a "first match" taken
  from a map range is nondeterministic. Sort the keys.
- `defer` in a loop holds every resource until the function returns. `defer` evaluates
  its arguments when it is declared, not when it runs.
- A zero-value struct accepted as valid: a new required field left unset compiles and
  runs with `""`, `0`, or `uuid.Nil`. Look at every literal and constructor of the type.
- A constant set gained a member. Every `switch` over it needs the new case; a
  `default:` that quietly absorbs it is a finding.
- `time.Time` compared with `==` instead of `Equal`. `time.Now()` in local time compared
  with UTC values from the database. Durations built from a bare integer.
- JSON: unexported fields are skipped silently; `omitempty` drops a real `0`, `false`,
  or `""`; `json.Unmarshal` into a reused struct keeps the old values of absent fields;
  an int64 above 2^53 loses precision in a JavaScript client.
- Build tags and file suffixes (`_linux.go`, `//go:build`): a file the default build,
  the linter, or the test profile never compiles. Run each tag set CI runs.

## Context and goroutines

- A goroutine started in a handler with `r.Context()`: the context is cancelled when
  the handler returns or the client disconnects, so the work dies midway. Work that must finish goes to a
  durable job, or uses `context.WithoutCancel` with its own timeout.
- A database or HTTP call that does not take the request context keeps running after
  the client has gone. A call that takes `context.Background()` has no deadline at all.
- `context.WithTimeout` or `WithCancel` without `defer cancel()` leaks the timer.
- A goroutine with no way to stop: no context, no closed channel, blocked forever on a
  send nobody receives. Ask what ends each `go` statement the change adds.
- A panic in a goroutine takes down the whole process; only the HTTP server's own
  handler goroutine is recovered.
- One goroutine per item with no bound. Use `errgroup` with `SetLimit`, and remember
  the group's context is cancelled once `Wait` returns.
- Shared map, slice, or struct field written from two goroutines without a mutex.
  Concurrent map writes crash the process. Run the tests with `-race`.
- A `sync.Mutex` copied because its struct is passed or received by value. Lock order
  that differs between two paths. A lock held across a network or database call.

## HTTP and chi

- Handler keeps going after `http.Error` or a redirect because the `return` is missing.
  The second write is dropped and the handler still performs its side effects.
- A new route registered outside the group that carries the auth, tenant, CSRF, or
  rate-limit middleware its neighbors have. Read the router, not the handler.
- Middleware order: recovery and request ID first, auth before anything that reads the
  user. A middleware added with `Use` after routes are defined panics at startup.
- An id from the URL or body used in a query with no tenant predicate is an IDOR.
  Check every `chi.URLParam` the change adds through to its SQL.
- Unbounded input: no `http.MaxBytesReader` on a body, no cap on a `limit` or page size
  query parameter, no cap on an uploaded file or a decoded list.
- `http.Server` without `ReadHeaderTimeout`; an outbound `http.Client` with no timeout
  (`http.DefaultClient` has none); a response body not closed, or closed without being
  read, which stops the connection being reused.
- A status code set after the body started writing is ignored. A template or JSON
  encoder that fails midway has already sent `200`; render to a buffer first.
- Redirect target taken from user input. Cookies without `Secure`, `HttpOnly`, and a
  `SameSite` choice. A state-changing GET.
- A response shape changed without its checked-in contract or generated client types.
  Old browser tabs still run the previous frontend during and after a deploy, so a
  removed or renamed field breaks them; add first, remove in a later release.

## pgx and Postgres

- SQL built with `fmt.Sprintf` or string concatenation from anything a caller controls.
  Values go through `$n` arguments; identifiers through `pgx.Identifier.Sanitize`.
- Every query on a tenant-owned table carries the tenant predicate, in handlers, jobs,
  admin tools, and exports. A join can drop it on the joined table.
- `rows.Close()` deferred and `rows.Err()` checked after the loop. An early return from
  a `rows.Next()` loop without Close leaves the connection busy; inside a transaction
  the next statement then fails with "conn busy".
- `QueryRow(...).Scan` returns `pgx.ErrNoRows`; did the caller want a 404, a zero
  value, or an error? `Exec` reports rows affected; an UPDATE or DELETE that matched
  nothing is success unless the code checks.
- NULL scanned into a non-pointer Go value errors at runtime, only on the row that has
  the NULL. Check new columns, LEFT JOIN columns, and aggregates over empty sets.
- A transaction without a deferred `Rollback`; a commit error ignored; a query run on
  the pool inside a function that holds a `tx`, which reads outside the transaction and
  can deadlock the pool under load.
- A transaction held open across an HTTP call, a file upload, or a model request.
- Per-row queries inside a loop. Read the set once with `= ANY($1)` and map by id. A
  JOIN that repeats a wide related row on every result row ships it once per row.
- Read-then-write without a lock or a constraint: two requests both pass the check.
  Use a unique constraint with `ON CONFLICT`, `SELECT ... FOR UPDATE`, or a conditional
  UPDATE. Take row locks in one order everywhere.
- A lock or write on a GET path. `pg_advisory_lock` on a pooled connection outlives the
  request; use `pg_advisory_xact_lock`.
- A list query with no `ORDER BY` paginated by offset, or ordered by a non-unique
  column, repeats and skips rows. A new filter or sort with no index behind it.
- A performance claim needs a test that pins how cost grows: statement count at two
  sizes, or rows the plan touches. A count on a three-row fixture proves nothing.

## Migrations

- An already-applied migration edited instead of a new one added. Two branches that
  took the same number.
- DDL that rewrites or locks a large table: a column added with a volatile default, a
  type change, `SET NOT NULL` without a prior validated check constraint, a foreign key
  added without `NOT VALID` then `VALIDATE`. Set a `lock_timeout`.
- `CREATE INDEX` without `CONCURRENTLY` on a live table. `CONCURRENTLY` cannot run in a
  transaction, and a failed run leaves an invalid index behind.
- Contract before expand: a column dropped or renamed while the running binary still
  reads it. The migration runs before the new code is live, and a rollback runs the old
  code against the new schema.
- A new foreign key with no `ON DELETE` rule and no index on the referencing column.
  A delete path that does not know about the new child table or its stored files.

## River and background jobs

- A job inserted outside the transaction that wrote its data. It can run before the
  row is visible, or run after a rollback. Insert with the transaction (`InsertTx`).
- Job args changed shape or a job `Kind` was renamed while old jobs are queued. Old
  rows no longer decode, or no worker claims them.
- A new job kind with no registered worker, or registered in only one of the processes
  that work its queue.
- Jobs run at least once. A handler that sends email, charges, or appends without an
  idempotency check does it again on retry. Args carry ids, and the handler reloads
  state and handles a row that is gone.
- Returning an error retries with backoff until attempts run out. Use `river.JobCancel`
  for an error that will never succeed and `river.JobSnooze` to wait without spending
  an attempt. Check what happens to the user-visible state when a job is discarded.
- No timeout on a job that calls a provider; a job that ignores context cancellation
  and blocks a deploy's graceful shutdown.
- A periodic job whose run can overlap its previous run, or whose schedule assumes a
  time zone. Unique-job options that no longer match because the args changed.

## Redis pub/sub and server-sent events

- Publish before commit: the subscriber refetches and reads the old row. Publish after
  commit, through an outbox if the notice must not be lost.
- Pub/sub does not store messages. A client that was disconnected missed them, so it
  must refetch on reconnect. A change that adds a live field needs that refetch too.
- Channel or event names that are not scoped by tenant leak one tenant's activity.
- An SSE handler that does not select on `r.Context().Done()` leaks a goroutine and a
  subscription per closed tab.
- A slow client blocks the fan-out loop for everyone. Each subscriber gets a buffered
  channel, and a full buffer drops or disconnects that subscriber.
- The server's `WriteTimeout` kills a long stream; a proxy buffers it unless told not
  to; an idle stream with no heartbeat is cut by a load balancer. Flush after each event.

## html/template and server-rendered pages

- `text/template` imported where `html/template` is needed: no escaping at all.
- `template.HTML`, `template.JS`, `template.URL`, or `template.CSS` wrapped around a
  value a user can influence switches escaping off for it.
- A field or function a template uses was renamed. Templates fail at execute time, on
  the page that uses them, not at compile time. Run or render each changed template.
- A new template or static file missing from the `//go:embed` pattern works locally
  from disk and 404s in the built binary.
- Form posts without the CSRF check their neighbors have. An invalid post that
  redirects and loses the user's input instead of re-rendering with field errors.

## Config, build and deploy

- `os.Getenv` returns `""` for a missing variable and the code carries on. A new
  variable is validated at startup and added to the example env file, the deploy
  config, CI, and the docs.
- Secrets, tokens, request bodies, or personal data in a log line or a structured log
  attribute. An error returned to the client that carries SQL or internal paths.
- Graceful shutdown: the server stops accepting, in-flight requests and jobs get a
  bounded time, and streams are closed. A new long-running loop needs a stop signal.
- Rolling deploy: old and new binaries run together against one schema, one queue, and
  one cache. Check every changed serialized format, cache key, and job payload.
- cgo: memory allocated in C is not freed by the garbage collector; a C call cannot be
  interrupted by context; a native library is missing from the build image.

## Tests

- A test that only runs under a build tag or a database profile CI does not run, so it
  never executes. Find the CI job that covers the new file.
- `t.Parallel()` on tests that share a database, a global, or an env var.
- A test that sleeps to wait for a goroutine, a job, or an event is a flake. Wait on a
  channel or poll with a deadline.
