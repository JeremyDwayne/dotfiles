# Django, DRF, Celery, Postgres/SQLite, Stripe traps

Read this when the repo is Django. Each item is a thing that has actually shipped and
broken; check the change against it.

## ORM and models

- `save()` vs `update()` vs `bulk_create`/`bulk_update`: the latter skip `save()`
  overrides, signals, `auto_now`, and validation. Was that intended? Does anything the
  model relies on (denormalized fields, search indexing, audit trail) now not fire?
- Signals (`post_save`, `pre_delete`, `m2m_changed`): new signal receiver connected in
  a module that is not imported until it happens to be; receiver that does I/O
  (email, HTTP, Celery) inside the transaction that has not committed yet.
- `transaction.on_commit` for anything that enqueues a task or calls out. A task
  enqueued inside `atomic()` can run before the row is visible, or after a rollback.
- `get()` raises `DoesNotExist` and `MultipleObjectsReturned`; `first()` returns None;
  `get_object_or_404`. Which one did the caller expect, and is the exception caught?
- QuerySet laziness: a queryset built in one place and evaluated later under different
  state, or `len(qs)` / `bool(qs)` forcing evaluation, or `qs.count()` in a loop.
- `select_related` / `prefetch_related` removed or not added for a new access in a loop
  or template (N+1). Check `Prefetch` `to_attr` names still match consumers.
- `unique=True` / `UniqueConstraint` on the model but no migration, or the reverse;
  `unique_together` on nullable columns (NULLs are distinct).
- Custom managers: `objects` overridden with a filtered manager and admin/migrations
  now can't see rows; `get_queryset` narrowing that leaks into `related` access.
- Choices/enums: value stored in DB changed; new choice not handled in every
  `if/elif`/`match` and template branch; `TextChoices` label vs value confusion.
- Money: `DecimalField` with explicit `max_digits`/`decimal_places`, or integer
  minor units. Never `FloatField`.
- `JSONField` schema drift: shape of the stored dict changed without a data migration.
- Multi-tenancy: every new query on tenant-owned tables filtered by the request's
  tenant/org, in views, serializers, admin, management commands and Celery tasks.
  `Model.objects.get(pk=pk)` in a view is a BLOCKER-level authorization check unless
  the model is genuinely global.
- Timezones: `USE_TZ=True` and naive `datetime.now()` / `date.today()` in code that
  compares against aware DB values; use `timezone.now()` / `timezone.localdate()`.

## Migrations

- Missing migration for a model change (`makemigrations --check`).
- `null=False` added without default on a populated table; Postgres `AddField` with a
  volatile default rewrites the table; `AlterField` type change locks the table.
- Index creation on a large table without `AddIndexConcurrently` (Postgres) inside a
  non-atomic migration.
- Data migration using the current model class instead of `apps.get_model()`.
- Migration that depends on code that will be removed in the same PR (management
  command, helper function) and therefore breaks on fresh installs later.
- Reverse migration present and correct; `RunPython` without `reverse_code`.
- Renamed field/model detected as drop+add (data loss) instead of `RenameField`.
- Migration merge conflicts (two leaf nodes on the same app).
- SQLite: `ALTER TABLE` limitations mean many `AlterField` operations recreate the
  table; on a large table that is downtime, and constraints/indexes must survive.

## Views, URLs and auth

- New view or endpoint without the auth decorator/mixin/permission class its neighbors
  have (`login_required`, `LoginRequiredMixin`, DRF `permission_classes`). Check the
  default permission in `REST_FRAMEWORK` settings and whether the view overrides it
  to something looser.
- Object-level authorization: `get_queryset()` scoped to `request.user`, not just
  `has_permission`. DRF `get_object()` uses `get_queryset()`, so an unscoped queryset
  is an IDOR.
- Serializers: new writable field that grants privilege (`owner`, `organization`,
  `is_staff`, `plan`, `status`, price fields); `fields = "__all__"` on a model that
  gained a sensitive column; `read_only_fields` not updated.
- `ModelForm` `Meta.fields` widened; `fields = "__all__"`.
- CSRF: `@csrf_exempt` added anywhere other than a verified webhook; API views that
  use session auth without CSRF.
- Redirects from user input (`next`, `return_to`) without `url_has_allowed_host_and_scheme`.
- Raw SQL: `.raw()`, `.extra()`, `cursor.execute()` with f-strings or `%` formatting.
- Templates: `|safe`, `mark_safe`, `{% autoescape off %}` on user-influenced content;
  `format_html` used with pre-formatted strings.
- URL ordering: a new broad pattern placed before a specific one shadows it.
- Uploads: `FileField` without `validators`/size limit; user-controlled `upload_to`.
- Pagination removed or unbounded list endpoints; `page_size` from query params
  without a max.
- Throttling on new public/unauthenticated endpoints.
- `ALLOWED_HOSTS`, `CSRF_TRUSTED_ORIGINS`, `SECURE_*` settings changes.

## HTMX / templates / frontend (if used)

- Partial template returned for HTMX requests but full page for direct navigation;
  `hx-target`/`id` mismatch means silent no-op.
- `hx-swap` OOB targets whose ids changed in the partial.
- CSRF header (`X-CSRFToken`) on HTMX non-GET requests.
- Static files: referenced asset not collected/hashed in production; template references
  a file that only exists locally.

## Celery / background tasks

- Task enqueued inside `atomic()` without `on_commit` (see above).
- Task args must be JSON-serializable; passing model instances or datetimes without
  the right serializer; passing a pk for a row that may be deleted before the task
  runs and not handling `DoesNotExist`.
- Renamed or removed task while old-name messages are queued; task name changed by
  moving the module.
- Non-idempotent task with `autoretry_for` / `acks_late`; retries without backoff;
  retrying non-retryable errors.
- `beat` schedule changes: timezone, overlap with the previous run, singleton
  assumptions.
- Missing `time_limit`/`soft_time_limit`; task doing an unbounded query.

## Settings and deploy

- New setting read with `settings.X` or `os.environ["X"]` with no default: raises at
  import in prod. Check it is in `.env.example`, deployment config, and docs.
- `DEBUG`, `SECRET_KEY`, DB credentials in code, fixtures, or committed `.env`.
- Static/media storage: new file writes outside the persistent volume; `MEDIA_ROOT`
  changes.
- Logging config that now prints request bodies, headers, or params.
- Rolling deploy: old and new code serving simultaneously with a changed serialized
  format, cache key, session shape, or Celery payload.
- Cache: key that no longer includes a value it depends on; write path that does not
  invalidate the read path's key.
- SQLite in production: single writer, so a long `atomic()` block or a transaction
  wrapping an external call blocks every other write; check `timeout` and WAL settings
  in `DATABASES["OPTIONS"]`; DB file must live on the persistent volume and be covered
  by backups.

## Stripe

- Webhook signature verification: `stripe.Webhook.construct_event` with the endpoint
  secret and the raw request body (`request.body`), not parsed JSON. `@csrf_exempt` on
  that view only. Verify before parsing.
- Idempotency: webhooks are delivered at least once and can arrive out of order.
  Handlers must be safe to run twice, and must not assume `checkout.session.completed`
  arrives before `invoice.paid` or `customer.subscription.updated`.
- Idempotency keys on write calls (`stripe.Customer.create`, `PaymentIntent.create`)
  when the caller may retry.
- Amounts in the smallest currency unit (cents), integer. Any float, any division, any
  `int()` on a rounded value is a finding.
- Test vs live keys: config that could send live keys to a non-production environment
  or the reverse. Keys or webhook secrets committed anywhere, including fixtures and
  recorded cassettes.
- Subscription state machine: `active`, `trialing`, `past_due`, `unpaid`, `canceled`,
  `incomplete`, `incomplete_expired`, `paused`. Does the new code handle every one it
  can receive, and does it fail closed (deny access) on unknown?
- Coupons/promotion codes: `duration` (once/repeating/forever), `max_redemptions`,
  `redeem_by` all applied? A "first N customers" coupon needs `max_redemptions` on the
  Stripe side, not just a counter in the app.
- Checkout / Customer Portal `success_url`/`return_url` built from params (open
  redirect).
- API version pinning: `stripe.api_version` set, and any change to it reviewed against
  the changelog for the objects the app reads.
- Prices vs plans; `unit_amount` is None for tiered/metered prices.
- Stripe calls inside `atomic()`: on rollback the charge still happened.

## Python general

- Mutable default arguments; class attributes used as instance state.
- `except Exception:` / bare `except:` swallowing errors; catching `Exception` where a
  specific one was meant; `except ... : pass`.
- Missing `await`; sync ORM call inside an async view without `sync_to_async`.
- `dict` key assumptions on external payloads (`payload["x"]` where the key is
  optional).
- Type hints that lie about `Optional`; new `None` return not handled by callers.
- `datetime` naive vs aware; `strptime` without tz; `date` vs `datetime` comparison.
- f-strings in logging (`logger.info(f"...")`) evaluating expensive things
  unconditionally; secrets in log messages.
- Requirements/lockfile drift: `pyproject`/`requirements.in` changed but lock not
  regenerated, or a new dependency unpinned.
- Tests: `TestCase` vs `TransactionTestCase` when the code uses `on_commit`
  (`captureOnCommitCallbacks`); `override_settings` leaking; `freezegun`/`time_machine`
  missing where time matters; mocking the thing under test.
