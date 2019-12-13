# frozen_string_literal: true

lock '3.11.2'

set :repo_url, ENV.fetch('REPO', 'https://github.com/tootsuite/mastodon.git')
set :branch, ENV.fetch('BRANCH', 'master')

set :application, 'mastodon'
set :migration_role, :app

append :linked_dirs, 'vendor/bundle', 'node_modules', 'public/system'
