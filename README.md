# rocket

A multi-tenant training platform that allows organizations to manage trainers and training content.

## Requirements

* Ruby 3.4.5
* Node.js
* PostgreSQL

## Getting started

Start the development database by running:

    $ docker compose -f .devcontainer/compose.yaml up postgres -d

Install development Node.js dependencies by running:

    $ npm install

Set up the development application by running:

    $ bin/setup

Start the development application server by running:

    $ bin/dev

## Testing

To run non-system tests, use:

    $ bin/rails test

To run system tests, use:

    $ bin/rails test:system

To run all tests, use:

    $ bin/rails test:all

## Linting

RuboCop is used for linting Ruby files. To run it in safe auto-correct mode, use:

    $ bundle exec rubocop -a

Herb is used for formatting and linting ERB files.

To lint ERB files, use:

    $ npm run herb:lint

To format ERB files, use:

    $ npm run herb:format

## Docs

* `docs/app_spec.txt` contains the application specification.
* `docs/feature_list.json` contains a prioritized list of features.

## Skills

To create a new GitHub issue, follow these steps:

1. Run the `pick-feature` skill to select a feature from the feature list.
2. Run the `draft-issue` skill to generate a draft of the new issue as a local Markdown file.
3. Run the `submit-issue` skill to submit the issue to GitHub.

To start working on an issue, follow these steps:

1. Run `pick-issue` with the issue number to read the issue. If the issue contains human todos, they will be added to `docs/issues/ISSUE_NUMBER/human_todos.md`.
2. Complete the human todos and run `commit-human-todos`.
3. Run `fix-issue` to implement a fix for the issue.

To start reviewing work, follow these steps:

1. Run `review-fix` with the issue number to review the changes. If fixes need to be made, they will be added as todos to `docs/issues/ISSUE_NUMBER/fix_todos.md`.
