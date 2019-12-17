# frozen_string_literal: true

lock '3.11.2'

set :repo_url, ENV.fetch('REPO', 'https://github.com/tootsuite/mastodon.git')
set :branch, ENV.fetch('BRANCH', 'master')

set :application, 'mastodon'
set :migration_role, :app


namespace :systemd do
  %i[sidekiq streaming web].each do |service|
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

  def systemctl(action, service)
    # runs e.g. "sudo restart mastodon-sidekiq.service"
    sudo :systemctl, action, "#{fetch(:application)}-#{service}.service"
  end
end

after 'deploy:publishing', 'systemd:web:reload'
after 'deploy:publishing', 'systemd:sidekiq:reload'
after 'deploy:publishing', 'systemd:streaming:reload'
