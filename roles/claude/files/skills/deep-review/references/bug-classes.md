# Bug classes to hunt for

Walk each category against the change. The questions are deliberately concrete; answer
each with "checked, fine because ..." or "finding" in your notes. Skipping a category is
allowed only when it plainly cannot apply (no concurrency in a pure formatting change),
and even then say so.

## Correctness

- Off-by-one and boundary: empty collections, single element, exactly-at-limit, negative,
  zero, max int, leap day, DST transition, end of month.
- Nil / null / undefined on every new dereference. Trace where the value comes from, do
  not trust the type annotation.
- Wrong operator or inverted condition (`<` vs `<=`, `&&` vs `||`, `!` misplaced,
  `unless ... else`).
- Early return that skips cleanup, logging, or a later required side effect.
- Copy-paste drift: two near-identical blocks where one was updated and the other was not.
- Default argument or default config value that changed meaning.
- Timezone: naive vs aware datetimes, `Date.today` vs `Time.current`, server tz vs user tz.
- Floating point for money or comparisons; integer division; string vs numeric comparison.
- Sorting/stability assumptions; hash/dict ordering assumptions.
- Regex: anchoring (`^`/`$` vs `\A`/`\z`), greedy vs lazy, catastrophic backtracking on
  user input, unescaped metacharacters.
- Encoding: bytes vs characters, non-ASCII, emoji, normalization.
- The change fixes the reported symptom but not the cause (the same root cause has other
  symptoms elsewhere).
- Behavior described in the PR/commit message that the code does not actually implement,
  or extra behavior the description does not mention.

## API and contract

- Signature change: every caller updated? Keyword vs positional, arity, renamed param.
- Return type or shape change: nil where an object was expected, array where a scalar
  was, hash key renamed, enum value added or removed.
- Exceptions: new exception type not caught by existing rescue; removed exception that a
  caller was relying on to trigger retry or rollback.
- Public interface (HTTP API, GraphQL schema, CLI flags, event payloads, library API):
  is this a breaking change for consumers outside this repo? Versioned?
- Serialization compatibility: JSON keys, protobuf field numbers, YAML/marshal formats,
  cache and queue payloads written by old code and read by new (and the reverse during
  a rolling deploy).
- Interface/protocol implementations: did an abstract method or interface change, and do
  all implementations still satisfy it?

## Concurrency and ordering

- Check-then-act races (find_or_create, exists? then insert, read-modify-write) without a
  lock or unique constraint.
- Shared mutable state: class variables, module constants mutated at runtime, memoization
  on a shared object, globals in a multi-threaded server.
- Transactions: is the unit of work atomic? Are there side effects (emails, jobs, HTTP
  calls) inside a transaction that fire even if it rolls back, or that run before commit
  so the job cannot see the row?
- Locking order across resources; lock held across a network call.
- Idempotency of jobs, webhooks, and retries. What happens if this runs twice?
- Time-of-check vs time-of-use on files, permissions, tokens.
- Async/promise/callback: unhandled rejection, missing await, fire-and-forget that
  should have been awaited.

## Security

- Authorization: is the new endpoint/action/query scoped to the current user, org, or
  tenant? Look for `find(params[:id])` where `current_user.things.find` was needed.
  Check the sibling endpoints too.
- Authentication: new route missing the auth filter that its neighbors have; skip_before
  filters widened.
- Mass assignment / strong params: new attribute added to a permit list that should not
  be user-settable (role, owner_id, price, status).
- Injection: SQL built with interpolation, shell commands with user input, HTML rendered
  raw, LDAP/XPath/regex built from input, header injection.
- SSRF and open redirect: user-controlled URLs fetched or redirected to.
- Secrets: keys, tokens, or credentials in code, logs, error messages, or test fixtures.
  New logging that prints request bodies or params.
- Crypto: home-rolled comparisons instead of constant-time, weak hashes, predictable
  tokens, missing signature verification on webhooks.
- File handling: path traversal, unrestricted upload type/size, temp file predictability.
- Rate limiting and abuse on new public endpoints; enumeration via error messages or
  timing.
- Dependency changes: new gem/package pinned? Known vulnerabilities? Does the lockfile
  match the manifest?

## Data and persistence

- Migration safety: adding a NOT NULL column without default on a large table, index
  without CONCURRENTLY (Postgres), renaming a column that live code still reads, dropping
  a column before the code that references it is gone.
- Backfill: existing rows left in an invalid state relative to new validations or code
  assumptions.
- Down migration: present, correct, and actually reversible?
- Constraint drift: validation added in the model but no DB constraint (or vice versa);
  uniqueness validated without a unique index.
- Cascades: `dependent:` options, foreign key on_delete behavior, orphaned records.
- Cache invalidation: new data path that writes without expiring the cache that reads it;
  cache key that no longer includes a value it depends on.
- Enum/state machine: new state added, but not handled in every `case`/`switch`; old
  state removed while rows still hold it.
- Precision and limits: column type too small (integer for a count that grows, string(255)
  for user text, decimal scale for currency).

## Performance

- N+1 queries introduced by a new association access in a loop or view.
- Unbounded queries: missing `limit`, `.all` loaded into memory, `count` where `exists?`
  suffices, `pluck` vs loading full records.
- Missing index for a new query predicate or ordering.
- Work moved into a hot path (per-request, per-row) that used to be per-process or cached.
- Synchronous external calls added to a request path.
- Large payloads: serializing whole objects where a few fields were needed; unbounded
  batch sizes in jobs.
- Algorithmic: nested loops over collections that can both be large; repeated linear
  scans where a set/hash was appropriate.

## Error handling and resilience

- Swallowed exceptions: `rescue => e` with no re-raise, log, or handling; bare `except:`;
  empty catch blocks.
- Overly broad rescue that hides programmer errors (NoMethodError, TypeError) as if they
  were expected failures.
- Retries without backoff, without idempotency, or that retry non-retryable errors.
- Timeouts: new network call with no timeout, or default timeout too long for the request
  budget.
- Partial failure: batch operation that fails midway leaves inconsistent state, or reports
  success for the whole batch.
- Error messages that leak internals or that are unhelpful to the operator.

## Operability and deploy

- Feature flags: default value correct? Flag check in every path or just one?
- Configuration: new env var required in production but no default, not documented, not
  added to deployment config or `.env.example`.
- Logging and metrics: a new critical path with no observability; or new logging at a
  level/volume that will flood.
- Rolling deploy compatibility (old and new versions serving simultaneously).
- Background job class renamed or removed while jobs of the old class are still queued.
- Cron/schedule changes; jobs that assume they are singleton.

## Tests

- New behavior with no test, or a test that would pass against the old code too.
- Tests that mock the thing under test, or mock so much that the assertion is vacuous.
- Assertions on the wrong thing (checks that no error was raised rather than that the
  result is right).
- Fixtures/factories changed in a way that silently changes what other tests exercise.
- Flaky patterns: order dependence, time dependence, shared state, `sleep`.
- Tests deleted or skipped in the PR. Why? Is the behavior they covered gone?

## Meta

- Scope creep: unrelated changes bundled in that need their own review.
- Dead code: the new code path is unreachable, or old code is now dead but left in place.
- TODO/FIXME/commented-out code introduced.
- Generated files edited by hand; lockfile inconsistent with manifest.
- Documentation, changelog, or API docs that now lie.
