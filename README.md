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
   rails server
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

If you ran `rails db:seed`, the development database includes the following accounts:

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@cuhk.edu.hk` | `Password1!` |
| **Staff** | `staff@cuhk.edu.hk` | `Password1!` |
| **Society Member** | `member@cuhk.edu.hk` | `Password1!` |

## Deployment

Deployed with heroku:
[https://cuhk-booking-system-33bfcf694971.herokuapp.com/](https://cuhk-booking-system-33bfcf694971.herokuapp.com/)

---

## Rubric Mapping

This section maps every grading criterion to the concrete files and features that satisfy it, so reviewers can locate evidence quickly.

### 1. Functionality

| Requirement | Status | Key Files / Evidence |
|---|---|---|
| **User Authentication** (login / logout) | ✅ | `app/controllers/sessions_controller.rb`, `app/models/user.rb` (`has_secure_password`), routes `GET/POST /login`, `DELETE /logout` |
| **Role-Based Access Control** (admin / staff / society member) | ✅ | `app/models/user.rb` (enum `role`), `application_controller.rb` (`require_admin`, `require_admin_or_staff`), `features/role_access.feature` |
| **Multi-Tenancy** (department / college isolation) | ✅ | `app/models/tenant.rb`, `tenant_id` FK on users, venues, equipment; scopes `visible_to_user`, `visible_to_student`, `Booking.for_tenant`; university-level sharing via `Tenant.university` |
| **Venue CRUD** | ✅ | `app/controllers/venues_controller.rb`, `app/models/venue.rb`, `app/views/venues/` |
| **Equipment CRUD + Borrow Flow** | ✅ | `app/controllers/equipments_controller.rb` (borrow_form, borrow actions), `app/models/equipment.rb`, `app/views/equipments/`, `features/equipment_booking.feature` |
| **Booking CRUD** (create / view / edit / delete) | ✅ | `app/controllers/bookings_controller.rb`, `app/models/booking.rb`, `app/views/bookings/` |
| **Booking Conflict Detection** | ✅ | `app/models/booking.rb` — `no_time_conflict` validation, hourly-slot rules (08:00–22:00), same-day constraint |
| **Timetable / Calendar UI** | ✅ | `bookings_controller.rb#new` (slot grid 08–22h), `app/views/bookings/new.html.erb`, `features/booking_timetable.feature` |
| **Approval Workflow** (pending → approved / rejected) | ✅ | `bookings_controller.rb#approve / #reject`, status enum in `booking.rb`, `dashboards_controller.rb#approvals`, `features/approval_workflow.feature` |
| **Email Notifications** (approval / rejection) | ✅ | `app/mailers/booking_mailer.rb` (approved, rejected), triggered in `bookings_controller.rb` |
| **Real-Time Updates** (ActionCable) | ✅ | `app/channels/booking_status_channel.rb`, `app/javascript/controllers/booking_status_controller.js`, `booking.rb#broadcast_status_change` |
| **Analytics Dashboard** (Chart.js) | ✅ | `app/controllers/analytics_controller.rb`, `app/views/analytics/show.html.erb`, `app/javascript/controllers/chart_controller.js`, 8+ chart types, date-range filter, venue + equipment metrics |
| **Admin Panel** | ✅ | `app/controllers/admin_controller.rb`, `app/views/admin/show.html.erb`, route `GET /admin` |

### 2. Engineering Quality

| Criterion | Status | Evidence |
|---|---|---|
| **MVC Architecture** | ✅ | Standard Rails 8.1 MVC: models in `app/models/`, controllers in `app/controllers/`, views in `app/views/` |
| **Database Design** (normalized, FKs, indexes) | ✅ | `db/schema.rb` — 6 tables (users, tenants, societies, venues, equipment, bookings) with foreign keys, unique indexes on `users.email` and `tenants.slug` |
| **RESTful Routes** | ✅ | `config/routes.rb` — resourceful routes for bookings, venues, equipment; named routes for auth and dashboards |
| **Security** (CSRF, password hashing, input validation) | ✅ | bcrypt `has_secure_password`, `reset_session` on login/logout, Rails CSRF protection, Brakeman + Bundler-audit in CI |
| **Code Style / Linting** | ✅ | RuboCop with Rails Omakase config, enforced in CI (`bin/rubocop -f github`) |

### 3. Testing

| Criterion | Status | Evidence |
|---|---|---|
| **Unit Tests** (RSpec models) | ✅ | `spec/models/` — user, booking, venue, equipment, tenant, society specs |
| **Request / Controller Tests** | ✅ | `spec/requests/` — sessions, bookings, venues, equipments, analytics, admin specs |
| **View Tests** | ✅ | `spec/views/` — analytics show, bookings views, venues views |
| **Routing Tests** | ✅ | `spec/routing/analytics_routing_spec.rb` |
| **BDD / Cucumber Features** | ✅ | `features/` — 8 feature files: authentication, approval_workflow, role_access, analytics_dashboard, equipment_booking, booking_timetable, venue_booking, college_and_university_booking |
| **Factories** (FactoryBot) | ✅ | `spec/factories/` — users, bookings, venues, equipment, tenants, societies |
| **Code Coverage ≥ 80%** | ✅ | SimpleCov (line 92.7%, branch 71.4%) with 80% minimum enforcement; Cobertura XML in `coverage/` |

### 4. CI / CD

| Criterion | Status | Evidence |
|---|---|---|
| **Automated Test Pipeline** | ✅ | `.github/workflows/ci.yml` — runs RSpec + Cucumber on every push/PR |
| **Security Scanning** | ✅ | CI jobs: `scan_ruby` (Brakeman + bundler-audit), `scan_js` (importmap audit) |
| **Linting in CI** | ✅ | CI job: `lint` (RuboCop with cache) |
| **Coverage Reporting** | ✅ | `CodeCoverageSummary` action writes to GitHub Step Summary; artifact upload (7-day retention) |
| **Deployment** | ✅ | Heroku live deployment + Kamal config (`config/deploy.yml`) + Dockerfile |

### 5. Project Management & Process

| Criterion | Status | Evidence |
|---|---|---|
| **Version Control** (Git + GitHub) | ✅ | GitHub repository with branch-based workflow |
| **CI Badge** | ✅ | README includes GitHub Actions CI status badge |
| **Seed Data for Review** | ✅ | `db/seeds.rb` — admin, staff, society_member accounts with documented credentials above |
| **Documentation** | ✅ | This README: setup guide, test commands, seed logins, deployment link, rubric mapping |

### Quick Reference — Rake Tasks

| Task | Purpose |
|---|---|
| `rake analytics:test` | Run analytics RSpec specs (requests + views + routing) |
| `rake analytics:cucumber` | Run `@analytics` Cucumber scenarios |
| `rake analytics:all` | Run both analytics RSpec and Cucumber |

### Architecture Overview

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Browser    │────▶│  Rails 8.1   │────▶│ PostgreSQL   │
│  (Turbo +    │◀────│  (Puma)      │◀────│   16         │
│   Stimulus)  │     └──────┬───────┘     └──────────────┘
└──────────────┘            │
       ▲                    │ ActionCable (WebSocket)
       │                    ▼
       └──── booking_status_channel ────┘

Asset Pipeline: Propshaft + Importmap (no Node.js required)
JS Libraries:  Chart.js (analytics), @hotwired/turbo, Stimulus
Background:    SolidQueue (in-process via Puma)
Caching:       SolidCache (database-backed)
```

