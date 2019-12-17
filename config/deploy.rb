# frozen_string_literal: true

lock '3.11.2'

set :repo_url, ENV.fetch('REPO', 'https://github.com/tootsuite/mastodon.git')
set :branch, ENV.fetch('BRANCH', 'master')

set :application, 'mastodon'
set :migration_role, :app

append :linked_dirs, 'vendor/bundle', 'public/system'

namespace :env_vars do
  desc 'Load environment variables'
  task :load do
    # Grab the current value of :default_env
    environment = fetch(:default_env, {})
    on roles(:app) do
      # Read in the environment file
      lines = capture("cat #{shared_path}/env")
      lines.each_line do |line|
        # Clean up the input by removing line breaks, tabs etc
        line = line.gsub /[\t\r\n\f]+/, ""
        # Grab the key and value from the line
        key, value = line.split("=")
        # Remove surrounding quotes if present
        value = value.slice(1..-2) if value.start_with?('"') and value.end_with?('"')
        # Store the value in our :default_env copy
        environment.store(key, value)
      end

      # Finally, update the global :default_env variable again
      set :default_env, environment
    end
  end
end

namespace :systemd do
  %i[mastodon-sidekiq mastodon-streaming].each do |service|
    desc "Reload #{service} service"
    task "#{service}:reload".to_sym do
      on roles(:app) do
        systemctl :reload, service
      end
    end

    desc "Show the status of #{service} service"
    task "#{service}:status".to_sym do
      on roles(:app) do
        systemctl :status, service
      end
    end
  end

  desc "Reload web service"
  task "web:reload".to_sym do
    on roles(:app) do
      systemctl :reload, "physalia_staging"
    end
  end

  desc "Show the status of web service"
  task "web:status".to_sym do
    on roles(:app) do
      systemctl :status, "physalia_staging"
    end
  end

  def systemctl(action, service)
    # runs e.g. "sudo restart mastodon-sidekiq.service"
    sudo :systemctl, action, "#{service}.service"
  end
end

after 'deploy:publishing', 'systemd:web:reload'
after 'deploy:publishing', 'systemd:sidekiq:reload'
after 'deploy:publishing', 'systemd:streaming:reload'

after 'deploy:starting', 'env_vars:load'
