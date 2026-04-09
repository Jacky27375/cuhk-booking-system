# CUHK Booking System

A room and facility booking system for CUHK departments and student societies.

## Local Setup

### Prerequisites

You need the following installed to run this project:
- **Ruby** (`3.4.8` or compatible)
- **PostgreSQL** (running locally on default port 5432)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd cuhk-booking-system
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database Setup**
   Ensure your local PostgreSQL server is running. You can use the default `postgres` user.
   
   Create the development databases and load the schema:
   ```bash
   rails db:create db:prepare
   ```

   Seed the database with dummy user accounts for testing:
   ```bash
   rails db:seed
   ```

4. **Start the server**
   ```bash
   bundle exec rails server
   ```
   The app will be available at [http://localhost:3000](http://localhost:3000).

## Testing

This project uses RSpec for unit testing and Cucumber for BDD/system testing.

To check test coverage directly from GitHub Actions:
[![Rspec/Cucumber CI](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/ci.yml/badge.svg)](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/ci.yml)

*(You can download the full HTML coverage reports for both RSpec and Cucumber from the **Artifacts** section of the latest CI build in GitHub Actions).*

Before running tests, ensure your test database is setup:
```bash
rails db:create db:prepare RAILS_ENV=test
```

**Run unit tests (RSpec):**
```bash
bundle exec rspec
```

**Run integration/feature tests (Cucumber):**
```bash
bundle exec cucumber
```

**Run rubocop_auto_corrector (automatically fix code style issues):**
```bash
bundle exec rubocop_auto_corrector
```

**Run bundler audit (security vulnerability check):**
```bash
bundle exec bundler-audit check --update
```

### Seed Data (Login details)

If you ran `rails db:seed`, the development database includes the following bootstrap accounts:

**Admin:**

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@link.cuhk.edu.hk` | `Password1!` |

**Root Staff Accounts (one per college, can create other staff):**

| College | Email | Password |
|---------|-------|----------|
| Chung Chi College | `staff_root_chungchi@link.cuhk.edu.hk` | `Password1!` |
| New Asia College | `staff_root_newasia@link.cuhk.edu.hk` | `Password1!` |
| United College | `staff_root_united@link.cuhk.edu.hk` | `Password1!` |
| Shaw College | `staff_root_shaw@link.cuhk.edu.hk` | `Password1!` |
| Morningside College | `staff_root_morningside@link.cuhk.edu.hk` | `Password1!` |
| S.H. Ho College | `staff_root_shho@link.cuhk.edu.hk` | `Password1!` |
| CW Chu College | `staff_root_cwchu@link.cuhk.edu.hk` | `Password1!` |
| Wu Yee Sun College | `staff_root_wuyeesun@link.cuhk.edu.hk` | `Password1!` |
| Lee Woo Sing College | `staff_root_leewoosin@link.cuhk.edu.hk` | `Password1!` |

Student accounts can be created via the signup page (students select their college during registration).

In production Docker deploys, startup now runs `db:seed` as well. This keeps college tenants, venue/equipment seed records, and bootstrap admin/root accounts present even on a fresh or previously unseeded database.

## Deployment (Azure VM)

Production URL: [https://csci3100.tylerl.cyou](https://csci3100.tylerl.cyou)

CI remains in `.github/workflows/ci.yml`, and CD is configured in `.github/workflows/deploy-azure.yml`.
The deploy workflow runs automatically after `CI` succeeds on `main`, and can also be triggered manually from GitHub Actions.

### 1. Add required GitHub repository secrets

| Secret | Value |
| --- | --- |
| `AZURE_VM_HOST` | Azure VM public IP or DNS name |
| `AZURE_VM_SSH_KEY` | Full private key content from `azure.pem` |
| `RAILS_MASTER_KEY` | Content of `config/master.key` |
| `POSTGRES_PASSWORD` | Password for the production Postgres container |
| `SECRET_KEY_BASE` | Required (`openssl rand -hex 64`) |
| `BOOTSTRAP_ACCOUNT_PASSWORD` | Optional but recommended. Password used when bootstrap admin/root accounts are first created in production. Defaults to `Password1!` if unset. |

### 2. Deploy

1. Merge/push to `main` (deploy runs after CI passes), or run **CD - Azure VM** manually in GitHub Actions.
2. The workflow uploads the repository to `/opt/cuhk-booking-system`, builds containers on the VM, and starts them with `deploy/docker-compose.azure.yml`.
3. It keeps recent releases and rolls back to the previous release automatically if health checks fail.

## Feature Ownership (Git History Summary)

Strict audit method for implemented features:
- Uses non-merge commits only.
- Uses line-impact weighting (added + deleted lines) over each feature's mapped files.
- Identity normalization: Joe = RiskyPork, Sam = Ga8riel520.
- Dependabot contributions are excluded from percentages.

| Implemented Feature | Contributors (Strict Audit %) | Notes |
| --- | --- | --- |

|Architecture Desing & Deploy | Joe

| Authentication & Role-Based Access | Jacky (57.2%), Tyler (29.9%), Sam (9.5%), Joe (RiskyPork) (3.4%) | User/session auth flow, role access scenarios, and seed-role foundations plus follow-up refinements. |

| CI, Coverage & Security Quality Gates | Tyler (54.5%), Jacky (43.5%), Joe (RiskyPork) (2.0%) | CI evolution, security scan hardening, and workflow/lint follow-up work. |

| Azure Deployment Pipeline & Health Checks | Tyler (57.9%), Jacky (41.0%), Joe (RiskyPork) (1.1%) | Azure CD pipeline, deployment compose wiring, diagnostics, and `/up` health-check support. |

| Venue Booking, Timetable & Conflict Handling | Jacky (73.7%), Joe (RiskyPork) (16.6%), Tyler (8.4%), Sam (1.3%) | Venue CRUD, timetable/slot UX, conflict checks, and booking confirmation flow with later hardening. |

| Multi-Tenant Isolation & Authorization Policies | Jacky (72.9%), Joe (RiskyPork) (26.9%), Sam (0.4%) | Policy/query authorization and tenant visibility controls with shared-resource scoping hardening. |

| Equipment Booking & Inventory Flow | Sam (56.2%), Jacky (30.0%), Joe (RiskyPork) (7.8%), Tyler (6.0%) | Equipment domain and borrow flow with validation/lifecycle refinements. |

| Approval Workflow & Lifecycle Transitions | Joe (RiskyPork) (56.4%), Tyler (21.0%), Jacky (20.6%), Sam (2.2%) | Approval dashboard, state transitions, and workflow tests/mail hooks with two-step and cancellation extensions. |

| Realtime Booking Status Updates (ActionCable) | Joe (RiskyPork) (81.3%), Jacky (18.7%) | Channel/stream status broadcasting for user bookings with frontend status handling. |

| Analytics Dashboard & Utilization Reporting | Sam (80.8%), Jacky (19.2%) | Analytics controller/views, chart rendering, trend/date filtering, and request/BDD coverage. |

| API v1 + SendGrid Email Integration | Joe (RiskyPork) (95.7%), Jacky (4.3%) | API-key auth, v1 endpoints, SendGrid delivery service wiring, and related specs. |

| Resource Table Sorting & Query Optimization | Jacky (54.5%), Sam (16.5%), Joe (RiskyPork) (16.2%), Tyler (12.8%) | Sortable listings for bookings/venues/equipment and Arel-based sorting refactor. |

### Future Ownership (Planning)

| Future Work Item | Planned Primary | Planned Secondary | Notes |
| --- | --- | --- | --- |
| Stabilize realtime approval @javascript scenarios | Joe | Tyler | Remaining work logs flag ActionCable/session timing instability; scenario synchronization still needs hardening. Tracking issue: [#40](https://github.com/Jacky27375/cuhk-booking-system/issues/40). |
| Final submission hardening run (full regression + production smoke evidence) | Sam | Tyler | Remaining runbook items include complete regression execution and production smoke-test evidence capture before final submission. Tracking issue: [#41](https://github.com/Jacky27375/cuhk-booking-system/issues/41). |
| README rubric traceability polish (coverage screenshot + concise mapping) | Tyler | Sam | Spec alignment can be improved by adding explicit coverage screenshot evidence and concise rubric-to-implementation traceability. Tracking issue: [#42](https://github.com/Jacky27375/cuhk-booking-system/issues/42). |
| Documentation consistency pass (README vs real behavior) | TBD | TBD | Verify setup/testing/deploy commands and required deployment secrets match current repository behavior exactly. Tracking issue: [#43](https://github.com/Jacky27375/cuhk-booking-system/issues/43). |
| Multi-tenant authorization edge-case regression pass | TBD | TBD | Re-test cross-tenant/cross-department isolation across booking and approval flows after recent merges. Tracking issue: [#44](https://github.com/Jacky27375/cuhk-booking-system/issues/44). |
| Staff dashboard realtime auto-update on new submissions | TBD | TBD | Initial team plan includes live updates for staff approval dashboard when new bookings arrive; current realtime wiring is focused on user booking status updates. Tracking issue: [#45](https://github.com/Jacky27375/cuhk-booking-system/issues/45). |
| Process audit evidence & contribution balance checkpoint | TBD | TBD | Add a final process-audit checkpoint to verify regular commit cadence and balanced per-member contribution evidence before submission. Tracking issue: [#46](https://github.com/Jacky27375/cuhk-booking-system/issues/46). |
| Cucumber key-user-journey coverage closure | TBD | TBD | Build a traceable checklist showing each required end-to-end user journey is covered by Cucumber scenarios and remains green in CI. Tracking issue: [#47](https://github.com/Jacky27375/cuhk-booking-system/issues/47). |
| Final submission artifact lock (Repo URL + SaaS URL + README evidence) | TBD | TBD | Add a release gate confirming Phase 2 submission artifacts are complete and cross-validated (repository link, live URL, video, README evidence). Tracking issue: [#48](https://github.com/Jacky27375/cuhk-booking-system/issues/48). |
| Concurrency-safe reservation enforcement | TBD | TBD | Harden venue/equipment reservation paths against race conditions with transaction/locking strategy and concurrent-request tests. Tracking issue: [#49](https://github.com/Jacky27375/cuhk-booking-system/issues/49). |
| Web/API authorization parity regression suite | TBD | TBD | Ensure API v1 and web controllers enforce identical tenant/role authorization behavior via shared policy checks and regression tests. Tracking issue: [#50](https://github.com/Jacky27375/cuhk-booking-system/issues/50). |
| Idempotent lifecycle actions for approval/cancel flows | TBD | TBD | Prevent duplicate transitions when approve/reject/cancel actions are retried, double-submitted, or race concurrently. Tracking issue: [#51](https://github.com/Jacky27375/cuhk-booking-system/issues/51). |
| Deterministic seed/reset runbook for TA demo reproducibility | TBD | TBD | Provide a single reset-and-seed flow that consistently generates all tenants, roles, resources, and booking states needed for demos. Tracking issue: [#52](https://github.com/Jacky27375/cuhk-booking-system/issues/52). |
| Timezone and boundary-condition booking tests | TBD | TBD | Add explicit tests for timezone-sensitive behavior, slot boundary edges, date rollover, and adjacent-time conflict handling. Tracking issue: [#53](https://github.com/Jacky27375/cuhk-booking-system/issues/53). |
| Async email delivery via Solid Queue jobs | TBD | TBD | Team plan targets background email delivery; current approval notification path still sends synchronously (`deliver_now`). Tracking issue: [#54](https://github.com/Jacky27375/cuhk-booking-system/issues/54). |
| Non-blocking warning cleanup | TBD | TBD | Resolve remaining runtime/tooling warnings (for example Ruby `fiddle`) as final submission polish. Tracking issue: [#55](https://github.com/Jacky27375/cuhk-booking-system/issues/55). |
| Demo rehearsal + final 5-minute video deliverable | TBD | TBD | Prepare and capture the required narrated end-to-end demo flow for final submission. Tracking issue: [#56](https://github.com/Jacky27375/cuhk-booking-system/issues/56). |
