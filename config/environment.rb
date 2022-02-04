require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require 'sidekiq/web'
require_relative '../lib/mind'
require_relative '../apps/web/application'

Hanami.configure do
  middleware.use Rack::Session::Cookie, secret: ENV['SESSIONS_SECRET']

  mount Web::Application, at: '/api'

  Sidekiq::Web.use Rack::Auth::Basic, "Protected Area" do |username, password|
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_ADMIN_USER"])) &
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_ADMIN_PASSWORD"]))
  end
  
  mount Sidekiq::Web, at: '/sidekiq'

  model do
    ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/mind_development.sqlite3'
    #    adapter :sql, 'postgresql://localhost/mind_development'
    #    adapter :sql, 'mysql://localhost/mind_development'
    #
    adapter :sql, ENV.fetch('DATABASE_URL')

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/mind/mailers'

    # See https://guides.hanamirb.org/mailers/delivery
    delivery :test
  end

  environment :development do
    # See: https://guides.hanamirb.org/projects/logging
    logger level: :debug
  end

  environment :production do
    logger level: :info, formatter: :json, filter: []

    mailer do
      delivery :smtp, address: ENV.fetch('SMTP_HOST'), port: ENV.fetch('SMTP_PORT')
    end
  end
end
