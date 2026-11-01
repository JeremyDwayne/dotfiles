# Stripe traps

Read this when the change touches Stripe, in any language. Each item is a thing that has
actually shipped and broken; check the change against it.

- Webhook signature verification: the SDK's construct-event call (`Webhook.construct_event`,
  `webhook.ConstructEvent`) with the endpoint secret and the raw request body, not parsed
  JSON or params. Verify before parsing. The webhook route is the only one exempt from
  CSRF, and it must verify.
- Idempotency: webhooks are delivered at least once and can arrive out of order.
  Handlers must be safe to run twice, and must not assume `checkout.session.completed`
  arrives before `invoice.paid` or `customer.subscription.updated`.
- Idempotency keys on write calls (`Customer.create`, `PaymentIntent.create`) when the
  caller may retry.
- Amounts in the smallest currency unit (cents), integer. Any float, any division, any
  integer conversion of a rounded value is a finding.
- Test vs live keys: config that could send live keys to a non-production environment or
  the reverse. Keys or webhook secrets committed anywhere, including fixtures and
  recorded HTTP cassettes.
- Subscription state machine: `active`, `trialing`, `past_due`, `unpaid`, `canceled`,
  `incomplete`, `incomplete_expired`, `paused`. Does the new code handle every one it can
  receive, and does it fail closed (deny access) on unknown?
- Coupons/promotion codes: `duration` (once/repeating/forever), `max_redemptions`,
  `redeem_by` all applied? A "first N customers" coupon needs `max_redemptions` on the
  Stripe side, not just a counter in the app.
- Checkout and Customer Portal `success_url`/`return_url` built from params (open
  redirect).
- API version pinning: the client's API version set, and any change to it reviewed
  against the changelog for the objects the app reads.
- Prices vs plans; `unit_amount` is null for tiered/metered prices.
- Stripe calls inside a database transaction: on rollback the charge still happened.
