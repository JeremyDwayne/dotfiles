# Go, pgx, River, chi, html/template traps

Read this when the repo has Go. Each item is a thing that has actually shipped and
broken; check the change against it.

## Errors and nil

- `%v` where `%w` was meant: the wrap drops the chain, and a caller's `errors.Is` or
  `errors.As` on that sentinel stops matching. Read every caller that checks the error.
- Sentinel compared with `==` after something in between started wrapping it.
- `err` shadowed by `:=` in an inner scope, so the outer function returns a nil error
  after a failure. Also `if err != nil { return nil }` (nilerr).
- A typed nil pointer returned as an `error` or other interface is not `== nil`. A
  function that returns `*MyErr` through `error` makes every `if err != nil` true.
- Writing to a nil map panics. A struct gained a map field: every constructor and zero
  value path initializes it before a write.
- Missing `return` after writing an error response (`http.Error`, a render helper): the
  handler keeps running, does the work, and writes a second response.
- `panic` in a goroutine the code started is not caught by the HTTP server's recovery and
  kills the process.

## Context and goroutines

- A new call path that drops `ctx`: `context.Background()` or `context.TODO()` on a
  request or job path loses cancellation, deadlines, and request-scoped values (request
  id, tenant, trace).
- A goroutine started from a handler that keeps using `r.Context()` after the handler
  returns: the context is already canceled.
- Goroutines with no exit: a send on a channel nobody reads, a loop with no
  `ctx.Done()` case, a ticker never stopped. Each one leaks per request.
- `errgroup` without `WithContext`, so one failure does not stop the others; or the
  group's `ctx` used after `Wait` returns.
- Shared mutable state: a package-level map or slice written per request, a cache with
  no lock. Concurrent map writes are a fatal error, not a recoverable panic. A struct
  holding a `sync.Mutex` copied by value (vet's copylocks).

## Database (pgx, sqlc)

- `Scan` destinations drift from the SELECT list: a column added, removed, or reordered
  in the SQL without the same change at every `Scan`. This fails only at runtime; a test
  that runs the query is the only check.
- A nullable column scanned into a non-pointer `string`, `int`, or `time.Time` fails on
  the first NULL row. A column made nullable in a migration needs every reader updated.
- `rows` not closed, or `rows.Err()` not checked after the loop: an error mid-iteration
  reads as a short, successful result. `pgx.CollectRows` handles both.
- `pgx.ErrNoRows` from `QueryRow().Scan` handled where "not found" is expected, and only
  there. A list query does not return it.
- Inside a transaction function, a query that uses the pool instead of the `tx`: it runs
  outside the transaction, sees uncommitted state differently, and survives a rollback.
- `SELECT ... FOR UPDATE` outside a transaction releases its lock when the statement
  ends, before the write it was meant to guard.
- SQL built with `fmt.Sprintf` from any value that is not a fixed identifier.
- Every tenant query carries the tenant predicate, including the `UPDATE` and `DELETE`
  that follow a scoped `SELECT`.
- Generated code (sqlc, `go generate`): regenerated after its source changed, never
  edited by hand. Run the generator and check for a diff.
- Migrations: `CREATE INDEX CONCURRENTLY` cannot run inside a transaction; a column
  dropped or renamed while the running release still reads it; `NOT NULL` added to a
  populated table without a backfill.

## Background jobs (River)

- A job inserted with `Insert` instead of `InsertTx` beside the write that caused it: the
  worker can run before the commit and not see the row, or run after a rollback.
- Side effects (email, HTTP, object storage writes) inside a transaction that can still roll back.
- Args are JSON. A field renamed or retyped while jobs are queued decodes to its zero
  value. A `Kind()` renamed or a worker unregistered leaves queued jobs failing.
- Handlers run at least once and retry on error. What happens if this one runs twice, or
  runs after the row it names was deleted? A deleted row is usually `JobCancel`, not an
  error that retries 25 times.
- Long work with no timeout, or a handler that ignores `ctx` and outlives shutdown.
- Periodic jobs run on the elected leader only; work that assumes it runs everywhere, or
  a periodic job added to a web process.

## HTTP (net/http, chi)

- A new route mounted outside the group whose middleware authenticates and loads the
  tenant is public. Read where it mounts, not what it is named.
- CSRF on every unsafe method the new route accepts.
- Request bodies read without `http.MaxBytesReader` or a size cap; uploads with no type or
  size check.
- `r.FormValue` merges the query string and the body; a value the code meant to read only
  from the body can come from the URL.
- Outbound calls: the default `http.Client` has no timeout; `resp.Body` not closed;
  requests built without the caller's `ctx` (noctx).
- Redirects and fetched URLs built from user input (open redirect, SSRF).
- Headers set or a status written after the body has started are ignored; the client
  gets the first status.

## Templates (html/template)

- `template.HTML`, `template.JS`, `template.URL`, or `template.HTMLAttr` around a value a
  user can influence turns escaping off.
- `text/template` imported where `html/template` was meant.
- A field renamed in the Go context struct and not in the template fails at execution,
  not at compile. Is there a test that renders the page?

## JSON and the wire

- A struct field renamed or its `json` tag changed: every client that reads the old key
  breaks, including open tabs still running the previous frontend. Follow the tag name
  into the client code and any checked-in schema.
- A nil slice encodes as `null`, an empty one as `[]`. A client that calls `.map` on the
  field breaks on `null`.
- `omitempty` on a `bool`, number, or string drops `false`, `0`, and `""` the client
  needs to see.
- Decoding ignores unknown fields and leaves missing ones at their zero value. A PATCH
  that cannot tell "absent" from "set to zero" overwrites data; it needs pointers or
  presence tracking.
- Unexported fields are skipped by `encoding/json` without an error.

## Time and numbers

- `time.Now()` stored or compared without `.UTC()` where the code assumes UTC; dates
  formatted in the server's zone instead of the user's.
- `time.Time` compared with `==`, which also compares location and the monotonic
  reading. Use `Equal`.
- The zero `time.Time` written as a real date where NULL was meant.
- `float64` for money; integer conversion that truncates a rounded value.

## Build, tags, and tools

- A test file behind a `//go:build` tag compiles only when the tag is set. `go test
  ./pkg` without it reports green for tests that never ran. Run the tag profile that
  covers each changed test file.
- A new tag-gated test or package is picked up by whatever runs that tag in CI.
- `go.mod` and `go.sum` tidy (`go mod tidy` leaves no diff); a new dependency is
  needed and maintained.
- A type that must satisfy an interface used only through `any` or reflection has a
  compile-time assertion (`var _ I = (*T)(nil)`), or a changed method set breaks it at
  runtime.
- Graceful shutdown: a new server, listener, or worker added to `main` is stopped and
  drained on SIGTERM.

## Tests

- `t.Fatal` or `t.FailNow` called from a goroutine other than the test's own.
- `t.Parallel()` on tests that share a database row, a package-level var, or an env var
  set with `os.Setenv` (use `t.Setenv`, which refuses parallel tests).
- A table test whose new case never reaches the new branch because an earlier field
  makes it return first.
- `testing.Short()` or a missing tag skipping the only test that covers the change.
- Tests run without `-race` when the change adds goroutines or shared state.
