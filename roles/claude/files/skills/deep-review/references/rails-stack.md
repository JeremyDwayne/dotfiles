# Rails, Hotwire, SQLite, Stripe traps

Read this when the repo is Rails or uses any of these. Each item is a thing that has
actually shipped and broken; check the change against it.

## ActiveRecord and models

- Callback ordering and side effects: `after_save` vs `after_commit`. Anything that
  enqueues a job, sends email, or calls an external API must be `after_commit`, or the
  job can run before the row is visible.
- `update_column` / `update_all` / `insert_all` / `upsert_all` skip validations and
  callbacks. Was that intended? Do callbacks the model relies on (counter caches,
  touch, search indexing) now not fire?
- `dependent: :destroy` vs `:delete_all` vs `:nullify`; missing `dependent` on a new
  `has_many` leaves orphans or raises on delete.
- Scopes returning `nil` when a `where` was expected (a class method with a conditional
  return breaks chaining).
- `default_scope` interactions with new queries; `unscoped` losing tenant scoping.
- `find_by` returns nil, `find` raises. Which one did the caller expect?
- Enum changes: adding a value in the middle of an integer-backed enum shifts every
  stored value after it. Enum removed while rows still hold it.
- `validates :x, uniqueness: true` without a unique index is a race.
- Money: `decimal` with explicit precision/scale or integer cents. Never `float`.
- Serialized/JSON columns: schema of the stored blob changed without migrating existing
  rows.
- Multi-tenancy: every new query on a tenant-owned table goes through the tenant
  association or a tenant scope. `Model.find(params[:id])` in a controller is a
  BLOCKER-level authorization check unless the model is genuinely global.

## Controllers and routes

- New action without the `before_action :authenticate_*` its neighbors have; `skip_before_action` added or widened.
- Strong params: newly permitted attribute that grants privilege (`role`, `admin`,
  `account_id`, `plan`, `status`, price fields).
- Redirects built from params (`redirect_to params[:return_to]`) without `allow_other_host: false` or an allowlist.
- New routes that expose more than intended (`resources :things` when only `show` was
  needed).
- Turbo: non-GET actions must respond to `turbo_stream` or redirect; a plain `render`
  of HTML to a Turbo form submission with status 200 will not replace the frame. Check
  `status: :unprocessable_entity` on validation failure.
- CSRF: `protect_from_forgery` skipped for a new endpoint that is not a webhook.

## Hotwire and views

- Turbo Frames: `dom_id` mismatch between the frame and the response means silent
  no-op. Check the target id in the stream/frame against the partial's id.
- Turbo Streams broadcast from model callbacks: `broadcasts_to` firing on every save
  including bulk operations; broadcasting to a stream name that includes a value that
  changed.
- Stimulus: controller identifier vs filename mismatch (`data-controller="foo-bar"` needs
  `foo_bar_controller.js`); targets and values renamed in JS but not in the HTML or vice
  versa; `connect()` doing work that should be in `initialize()` or that runs again on
  every Turbo cache restore.
- `html_safe` / `raw` on anything user-influenced.
- Turbo Drive cache: pages that show flash or one-time state may re-show it on back
  navigation; forms that should be `data-turbo="false"`.
- Importmap pins: new JS dependency added in JS but not pinned, or pinned to a URL that
  is not vendored.

## SQLite in production (Rails 8 style)

- Single writer: long transactions or long-running writes block every other write.
  Look for a transaction wrapping an external call or a large loop.
- Migrations that rewrite the table (SQLite cannot `ALTER COLUMN`; Rails emulates by
  copying the table). On a large table that is downtime, and it drops indexes/triggers
  unless the migration re-adds them.
- `busy_timeout`, `journal_mode = WAL`, `synchronous` set in `database.yml`? A new
  database or a changed config that loses these causes `database is locked` errors.
- Solid Queue / Solid Cache / Solid Cable on the same SQLite file as the app: write
  contention. Are they in separate databases?
- Volume mount: DB file path outside the persistent volume means data loss on deploy.
- Backups: a change to the DB path or a new database file that the backup script does
  not know about.
- `LIKE` is case-insensitive for ASCII only; `ILIKE` does not exist; string comparison
  and collation differ from Postgres. Full-text search behaves differently.
- Boolean stored as 0/1; date/time stored as text. Raw SQL comparing these breaks in ways
  ActiveRecord hides.

## Background jobs (Solid Queue, Sidekiq, GoodJob)

- Enqueued inside a transaction (see `after_commit` above).
- Job arguments must be serializable; passing a record that may be deleted before the
  job runs raises `DeserializationError`. Is that handled or retried into oblivion?
- Renamed or deleted job class while jobs of the old name are queued.
- Non-idempotent job that will be retried.
- Recurring job schedule changes: timezone of the schedule, overlap with the previous
  run.

## Stripe

- Webhook signature verification: `Stripe::Webhook.construct_event` with the endpoint
  secret, and the raw body (not parsed params). A new webhook route must be excluded
  from CSRF and must verify.
- Idempotency: webhooks are delivered at least once and can arrive out of order.
  Handlers must be safe to run twice, and must not assume `checkout.session.completed`
  arrives before `invoice.paid`.
- Idempotency keys on write calls (`Stripe::Customer.create`, `PaymentIntent.create`)
  when the caller may retry.
- Amounts in the smallest currency unit (cents), integer. Any float, any division, any
  `to_i` on a rounded value is a finding.
- Test vs live keys: config that could send live keys to a non-production environment or
  the reverse. Keys or webhook secrets committed anywhere, including fixtures and VCR
  cassettes.
- Subscription state machine: `active`, `trialing`, `past_due`, `unpaid`, `canceled`,
  `incomplete`, `incomplete_expired`, `paused`. Does the new code handle every one it can
  receive, and does it fail closed (deny access) on unknown?
- Coupons/promotion codes: `duration` (once/repeating/forever), `max_redemptions`,
  `redeem_by` all applied? A "first N customers" coupon needs `max_redemptions` on the
  Stripe side, not just a counter in the app.
- Customer portal and Checkout return URLs built from params (open redirect).
- API version pinning: `Stripe.api_version` set, and any change to it reviewed against
  the changelog for the objects the app reads.
- Prices vs plans; `unit_amount` nil for tiered/metered prices.

## Rails general

- `Rails.cache` keys that include an object whose `cache_key` no longer changes when the
  relevant data changes.
- `Time.now` / `Date.today` instead of `Time.current` / `Date.current`.
- `config.hosts`, `config.action_dispatch.trusted_proxies`, `force_ssl` changes.
- Credentials: `Rails.application.credentials` key added but not in every environment's
  encrypted file; `ENV.fetch` without default that will raise at boot in prod.
- Zeitwerk: new file whose constant name does not match its path (works in dev with
  reloading, fails in eager-loaded prod). Run `bin/rails zeitwerk:check`.
- Asset pipeline / Propshaft: referenced asset not in the manifest; `image_tag` for a
  file that only exists in dev.
- `rescue_from` ordering (more specific after less specific never fires).
- Mailer changes: `deliver_later` from a callback before commit; previews not updated;
  `default_url_options` missing host in a new environment.
