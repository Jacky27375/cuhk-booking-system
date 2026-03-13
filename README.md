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

