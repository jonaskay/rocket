## Commands

- Setup application locally: `bin/setup`
- Start development server: `bin/dev`
- Start development database: `docker compose -f .devcontainer/compose.yaml up postgres -d`

## Validations

- Run non-system tests: `bin/rails test`
- Run system tests: `bin/rails test:system`
- Lint Ruby files: `bundle exec rubocop`
- Format ERB files: `npm run herb:format`
- Lint ERB files: `npm run herb:lint`
