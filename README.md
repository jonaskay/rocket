# rocket

A multi-tenant training platform that allows organizations to manage trainers and training content.

## Requirements

* Ruby 3.4.5
* Node.js
* PostgreSQL

## Getting started

Start the development database by running:

    $ docker compose up postgres -d

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
* `docs/glossary.md` contains definitions for important domain terms.

## Skills

### issue — Create a new GitHub issue

1. `issue.pick` — select a feature from the feature list
2. `issue.draft` — generate a draft as a local Markdown file
3. `issue.submit` — submit the issue to GitHub

### dev — Work on an issue

1. `dev.pick <issue>` — read the issue; human todos → `docs/issues/ISSUE/human_todos.md`
2. Complete the human todos, then run `dev.commit-todos`
3. `dev.fix` — implement the fix

### review — Review the work

1. `review.start <issue>` — review changes; fix todos → `docs/issues/ISSUE/fix_todos.md`
2. In a new session, `review.fix <issue>` — address the findings

### pr — Ship it

1. `pr.submit <issue>` — open the pull request
2. `pr.fix <pull-request>` — fix failing jobs
