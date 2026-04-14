# CUHK Booking System

[![CI](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/ci.yml/badge.svg)](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/ci.yml)
[![CD](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/deploy-azure.yml/badge.svg)](https://github.com/Jacky27375/cuhk-booking-system/actions/workflows/deploy-azure.yml)

CUHK Booking System is **Option A** from the CSCI3100 Spring 2026 project spec: a multi-tenant SaaS for booking venues and equipment across CUHK colleges, with conflict detection and approval workflows.

## 1. Spec Alignment

This repository aligns with the key spec requirements:

- **SaaS + multi-tenant architecture** (college/university scoped resources and authorization)
- **Core feature coverage** (booking conflict checks + approval workflow)
- **Testing stack required by spec** (`RSpec` + `Cucumber`) integrated in GitHub Actions
- **Public cloud deployment** (Azure VM deployment workflow + `/up` health check)

## 2. Tech Stack

- **Ruby:** `3.4.8` (`.ruby-version`)
- **Rails:** `~> 8.1.2` (`Gemfile`)
- **Database:** PostgreSQL (multi-db roles: `primary`, `cache`, `queue`, `cable`)
- **Frontend:** ERB + Turbo + Stimulus
- **Realtime:** ActionCable
- **Testing:** RSpec, Cucumber, SimpleCov

## 3. Local Development Setup

### Prerequisites

- Git
- Ruby `3.4.8` (see `.ruby-version`)
- Bundler (`gem install bundler`)
- PostgreSQL reachable at `127.0.0.1:5432` with user/password `postgres`/`postgres` (defaults in `config/database.yml`)

You can provide PostgreSQL in either way:

1. Local PostgreSQL service
2. Docker container (recommended):

```bash
# First time only (create container)
docker run -d \
  --name cuhk-booking-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -v cuhk-booking-postgres-data:/var/lib/postgresql/data \
  postgres:16

# Next runs
docker start cuhk-booking-postgres
```

### Start locally

```bash
git clone <repository_url>
cd cuhk-booking-system
# If using Docker Postgres and container already exists:
# docker start cuhk-booking-postgres
bin/setup --skip-server
bin/dev
```

The app is available at: `http://localhost:3000`

### Reset + reseed demo data

```bash
bin/rails reset
```

`bin/rails reset` maps to `db:reset` and reseeds the project demo dataset.

## 4. Test and Quality Commands

Before running test suites:

```bash
RAILS_ENV=test bin/rails db:create db:prepare
```

| Purpose | Command |
| --- | --- |
| RSpec suite | `bundle exec rspec` |
| Cucumber suite | `bundle exec cucumber` |
| Rails test suite | `bin/rails test` |
| RuboCop | `bin/rubocop` |
| Brakeman | `bin/brakeman --no-pager` |
| Bundler audit | `bin/bundler-audit` |
| Importmap audit | `bin/importmap audit` |
| Local CI script | `bin/ci` |
| Match GitHub CI checks locally | `bin/rubocop && bin/brakeman --no-pager && bin/bundler-audit && bin/importmap audit && bundle exec rspec && bundle exec cucumber` |

The following canonical journeys are covered by stable Cucumber scenarios:

| Journey ID | Canonical journey | Scenario coverage | Expected outcome |
| --- | --- | --- | --- |
| J-01 | Authentication and role access | [features/authentication.feature](features/authentication.feature) scenarios: `Successful login as admin`, `Successful login as staff`, `Successful login as student`, `Failed login with incorrect password`, `Failed login with non-existent email`, `User logs out`, `Unauthenticated user is redirected to login`; [features/role_access.feature](features/role_access.feature) scenarios: `Admin can access admin panel`, `Admin dashboard hides My Bookings link`, `Admin cannot access My Bookings page directly`, `Admin cannot edit a booking` | Users can sign in and are blocked from unauthorized areas. |
| J-02 | Venue booking slot selection and validation | [features/booking_timetable.feature](features/booking_timetable.feature) scenarios: `Timetable shows booked and available slots for selected date`, `Unavailable start time options are hidden`, `End time appears only after start time and only shows valid slots`, `Booking with non hourly increments is rejected`, `Selected slot is highlighted on edit page` | Available slots are shown first, invalid times stay hidden or rejected, and the selected slot remains visible during edits. |
| J-03 | Booking approval lifecycle | [features/approval_workflow.feature](features/approval_workflow.feature) scenarios: `Staff sees pending booking requests`, `Staff approves a booking`, `Two-step tenant requires two approvals before final approval`, `Staff cannot manage bookings from another department`, `Staff cannot approve another department booking via direct request`, `Society member cannot access approval dashboard`, `Society member can cancel own pending booking`, `Pending booking is automatically rejected after its booking date passes`, `Student is notified in real-time when booking is approved` | Staff can review and act on bookings, unauthorized users are blocked, expired pending bookings are auto-rejected, and approvals trigger notifications. |
| J-04 | Venue request submission and admin review | [features/venue_requests.feature](features/venue_requests.feature) scenarios: `Staff can submit a venue request`, `Admin can approve a venue request`, `Admin can reject a venue request`, `Admin panel links directly to pending venue-request review`, `Admin sees all pending staff venue requests on approval dashboard`, `Staff approval dashboard does not show pending venue requests`, `Student cannot access venue requests` | Staff can submit requests, admins can review and see all pending requests, and non-admin users do not see the admin request queue. |

Each journey above has at least one positive scenario and, where it matters, a stable negative-path check.

## 5. Seed Data and Demo Accounts

Running `bin/rails reset` or `bin/rails db:seed` ensures:

- 10 tenants total (**9 colleges + University**)
- Seeded venue and equipment records from `db/seeds.rb`
- Seeded demo bookings (one venue booking + one equipment booking per demo student)
- Seeded staff-submitted request records (venue and equipment-themed)
- Bootstrap admin/root/demo user accounts

### Seed password behavior

- **Development/Test:** `DEV_BOOTSTRAP_ACCOUNT_PASSWORD` if set, otherwise `Password1!`
- **Production:** `BOOTSTRAP_ACCOUNT_PASSWORD` is required

### Login accounts

**Admin**

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@link.cuhk.edu.hk` | `Password1!` (unless overridden by bootstrap env vars above) |

**Root staff + demo student (one per college)**

| College | Root staff email | Demo student email |
| --- | --- | --- |
| Chung Chi College | `staff_root_chungchi@link.cuhk.edu.hk` | `demo_student_chungchi@link.cuhk.edu.hk` |
| New Asia College | `staff_root_newasia@link.cuhk.edu.hk` | `demo_student_newasia@link.cuhk.edu.hk` |
| United College | `staff_root_united@link.cuhk.edu.hk` | `demo_student_united@link.cuhk.edu.hk` |
| Shaw College | `staff_root_shaw@link.cuhk.edu.hk` | `demo_student_shaw@link.cuhk.edu.hk` |
| Morningside College | `staff_root_morningside@link.cuhk.edu.hk` | `demo_student_morningside@link.cuhk.edu.hk` |
| S.H. Ho College | `staff_root_shho@link.cuhk.edu.hk` | `demo_student_shho@link.cuhk.edu.hk` |
| CW Chu College | `staff_root_cwchu@link.cuhk.edu.hk` | `demo_student_cwchu@link.cuhk.edu.hk` |
| Wu Yee Sun College | `staff_root_wuyeesun@link.cuhk.edu.hk` | `demo_student_wuyeesun@link.cuhk.edu.hk` |
| Lee Woo Sing College | `staff_root_leewoosing@link.cuhk.edu.hk` | `demo_student_leewoosing@link.cuhk.edu.hk` |

Student self-registration is also available on `/signup` and is restricted to the college allow-list in `RegistrationsController`.

## 6. API v1 Quick Reference

Authentication:

- `Authorization: Bearer <api_key>` header (preferred), or
- `api_key` request parameter (fallback)

API routes (`config/routes.rb`):

- `GET /api/v1/venues`
- `GET /api/v1/venues/:id`
- `GET /api/v1/equipment`
- `GET /api/v1/equipment/:id`
- `GET /api/v1/bookings`
- `GET /api/v1/bookings/:id`
- `POST /api/v1/bookings`

Role scoping is consistent with web behavior:

- Admin: all records
- Staff: tenant-scoped records
- Student: own bookings only

## 7. Implemented Features and Ownership

Ownership is summarized from repository contribution history (aliases used in history: **Joe = RiskyPork**, **Sam = Ga8riel520**).

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
| API v1 + Resend Email Integration | Joe (RiskyPork) (95.7%), Jacky (4.3%) | API-key auth, v1 endpoints, Resend delivery service wiring, and related specs. |
| Resource Table Sorting & Query Optimization | Jacky (54.5%), Sam (16.5%), Joe (RiskyPork) (16.2%), Tyler (12.8%) | Sortable listings for bookings/venues/equipment and Arel-based sorting refactor. |

## 8. Coverage Evidence (SimpleCov)

SimpleCov is enabled with `minimum_coverage 80` in `.simplecov`.

After running test suites, coverage artifacts are available at:

- Local HTML report: `coverage/index.html`
- Local Cobertura XML: `coverage/coverage.xml`
- GitHub Actions artifact: `merged-coverage-report`

#### SimpleCov Report
![SimpleCov Report](./SimpleCov_Report.png)

## 9. Deployment (Azure VM)

Production URL: `https://csci3100.tylerl.cyou`

- CI workflow: `.github/workflows/ci.yml`
- CD workflow: `.github/workflows/deploy-azure.yml`
- Runtime compose file: `deploy/docker-compose.azure.yml`

### Required GitHub repository secrets

| Secret | Required | Notes |
| --- | --- | --- |
| `AZURE_VM_HOST` | Yes | VM public IP or DNS |
| `AZURE_VM_SSH_KEY` | Yes | Private key content for SSH |
| `RAILS_MASTER_KEY` | Yes | Must match `config/credentials.yml.enc` |
| `SECRET_KEY_BASE` | Yes | Generate with `openssl rand -hex 64` |
| `POSTGRES_PASSWORD` | Yes | Production Postgres password |
| `BOOTSTRAP_ACCOUNT_PASSWORD` | Yes | Required by `db/seeds` in production |
| `RESEND_API_KEY` | Yes | Required for email delivery |
| `RESET_BOOTSTRAP_ACCOUNTS_ONCE` | Optional | One-time password reset switch for bootstrap accounts |

### Deployment behavior

The CD workflow deploys to `/opt/cuhk-booking-system`, starts containers with Docker Compose, and health-checks `GET /up`. On failed health checks, it rolls back to the previous release automatically.
