# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
# Start development server with auto-reload
bin/dev

# Run Rails server only
bin/rails server

# Run Rails console
bin/rails console

# Generate Rails components
bin/rails generate controller ControllerName
bin/rails generate model ModelName
bin/rails generate migration MigrationName
```

### Database
```bash
# Setup database
bin/rails db:setup

# Run migrations
bin/rails db:migrate

# Rollback migrations
bin/rails db:rollback

# Reset database
bin/rails db:reset
```

### Assets
```bash
# Build JavaScript assets
yarn build

# Build CSS assets
yarn build:css

# Watch assets for changes (development)
yarn watch
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -A

# Run HAML linter
bundle exec haml-lint app/views/

# Run security analysis
bundle exec brakeman
```

### Deployment
```bash
# Deploy with Kamal
kamal deploy

# Build Docker image
docker build -t popondana .
```

## Architecture

### Technology Stack
- **Framework**: Rails 8.0.2 with Ruby 3.4.4
- **Database**: PostgreSQL
- **Frontend**: Hotwired (Turbo + Stimulus) with Bootstrap 5.3.7
- **Assets**: esbuild for JavaScript, Sass for CSS, Propshaft for asset pipeline
- **Templates**: HAML
- **Deployment**: Dockerized with Kamal orchestration

### Key Patterns
- Uses Hotwired for SPA-like frontend behavior without complex JavaScript frameworks
- HAML templates with Bootstrap components via SimpleForm integration
- Stimulus controllers for JavaScript interactions in `app/javascript/controllers/`
- Standard Rails MVC architecture with minimal API endpoints

### Localization
- Primary language: Japanese (`:ja`)
- Timezone: Tokyo
- Locale files in `config/locales/`

### Development Environment
- `bin/dev` runs Rails server + asset watchers via Procfile.dev
- Assets auto-compile during development
- Ruby debug enabled for development server

### Code Standards
- RuboCop with SonicGarden's sgcop rules for Ruby code style
- HAML-lint for template consistency
- Brakeman for security scanning

### Current Branch Context
Working on `google-login` branch - implementing Google OAuth authentication feature.