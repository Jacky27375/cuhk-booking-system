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

If you ran `rails db:seed`, the development database includes the following accounts:

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@link.cuhk.edu.hk` | `Password1!` |
| **Staff** | `staff@link.cuhk.edu.hk` | `Password1!` |
| **Society Member** | `member@link.cuhk.edu.hk` | `Password1!` |

Additional cross-tenant test accounts are also created by seeds:

| Role | Tenant | Email | Password |
|------|--------|-------|----------|
| **Staff** | Shaw College | `staff.shaw@link.cuhk.edu.hk` | `Password1!` |
| **Staff** | New Asia College | `staff.newasia@link.cuhk.edu.hk` | `Password1!` |
| **Staff** | Wu Yee Sun College | `staff.wys@link.cuhk.edu.hk` | `Password1!` |
| **Society Member** | Shaw College | `member.shaw@link.cuhk.edu.hk` | `Password1!` |
| **Society Member** | New Asia College | `member.newasia@link.cuhk.edu.hk` | `Password1!` |
| **Society Member** | Wu Yee Sun College | `member.wys@link.cuhk.edu.hk` | `Password1!` |

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

### 2. Deploy

1. Merge/push to `main` (deploy runs after CI passes), or run **CD - Azure VM** manually in GitHub Actions.
2. The workflow uploads the repository to `/opt/cuhk-booking-system`, builds containers on the VM, and starts them with `deploy/docker-compose.azure.yml`.
3. It keeps recent releases and rolls back to the previous release automatically if health checks fail.
