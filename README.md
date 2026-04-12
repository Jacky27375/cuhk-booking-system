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

- Ruby `3.4.8`
- PostgreSQL running locally (defaults from `config/database.yml`: host `127.0.0.1`, port `5432`, user `postgres`, password `postgres`)

### Start locally

```bash
git clone <repository_url>
cd cuhk-booking-system
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
| Lee Woo Sing College | `staff_root_leewoosin@link.cuhk.edu.hk` | `demo_student_leewoosin@link.cuhk.edu.hk` |

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

| Implemented feature | Primary | Secondary | Evidence |
| --- | --- | --- | --- |
| Architecture design and deploy baseline | Joe | — | `Dockerfile`, `deploy/docker-compose.azure.yml`, `.github/workflows/deploy-azure.yml` |
| Authentication and role-based access | Jacky | Tyler | `SessionsController`, `ApplicationController`, `features/authentication.feature`, `features/role_access.feature` |
| CI, coverage, and security quality gates | Tyler | Jacky | `.github/workflows/ci.yml`, `bin/ci`, security/lint commands in `bin/*` |
| Azure deployment pipeline and health checks | Tyler | Jacky | `.github/workflows/deploy-azure.yml`, `deploy/docker-compose.azure.yml`, `config/routes.rb` (`/up`) |
| Venue booking timetable and conflict handling | Jacky | Joe | `BookingsController` timetable flow, `VenueBooking`, `BookingConflictChecker` |
| Multi-tenant isolation and authorization policies | Jacky | Joe | `Venue.visible_to_user`, `Equipment.visible_to_user`, `BookingScopeQuery`, `BookingAccessPolicy` |
| Equipment booking and inventory flow | Sam | Jacky | `EquipmentBooking`, `Equipment#available_quantity`, `features/equipment_booking.feature` |
| Approval workflow and lifecycle transitions | Joe | Tyler | `DashboardsController#approvals`, `BookingsController#approve/#reject`, `ApprovalStep`, `features/approval_workflow.feature` |
| Realtime booking status updates (ActionCable) | Joe | Jacky | `BookingStatusChannel`, `Booking#broadcast_status_change`, `booking_status_controller.js` |
| Analytics dashboard and utilization reporting | Sam | Jacky | `AnalyticsController`, `app/views/analytics/show.html.erb`, Chart.js integration |
| API v1 and Resend email integration | Joe | Jacky | `Api::V1::*Controller`, `ApiAuthenticatable`, `ResendEmailService` |
| Resource table sorting and query optimization | Jacky | Sam | sorting branches in `BookingsController`/`VenuesController`/`DashboardsController` |

## 8. Coverage Evidence (SimpleCov)

SimpleCov is enabled with `minimum_coverage 80` in `.simplecov`.

After running test suites, coverage artifacts are available at:

- Local HTML report: `coverage/index.html`
- Local Cobertura XML: `coverage/coverage.xml`
- GitHub Actions artifact: `merged-coverage-report`

For submission packaging, capture the screenshot directly from `coverage/index.html` after your latest full test run.

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
| `RESEND_API_KEY` | Optional | Required only for live Resend delivery |
| `RESET_BOOTSTRAP_ACCOUNTS_ONCE` | Optional | One-time password reset switch for bootstrap accounts |

### Deployment behavior

The CD workflow deploys to `/opt/cuhk-booking-system`, starts containers with Docker Compose, and health-checks `GET /up`. On failed health checks, it rolls back to the previous release automatically.
