source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Connection pooling and database monitoring
gem "connection_pool", "~> 2.4"  # Robust connection pooling
gem "pghero", "~> 3.4"           # PostgreSQL metrics and insights
gem "redis-client", "~> 0.19"    # Modern Redis client with built-in connection pooling

# Health checks and monitoring
gem "okcomputer", "~> 1.18"      # Comprehensive health check endpoints with authentication

# OpenTelemetry for monitoring and tracing
gem "opentelemetry-sdk"          # Base OpenTelemetry SDK
gem "opentelemetry-exporter-otlp" # OTLP exporter for OpenTelemetry
gem "opentelemetry-instrumentation-all" # Auto-instrumentation for all supported gems
gem "opentelemetry-semantic_conventions" # Standard semantic conventions
gem "lograge-sql"               # SQL query logging for lograge

# Deployment tools
gem "kamal", require: false  # Container deployment

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# authentication and authorization gems
# gem "jwt"
gem "devise", "~> 4.9"
gem "devise_token_auth", "~> 1.2"
gem "omniauth", "~> 2.1"
gem "stripe"
gem "pay", "~> 8.3.0"
gem "pundit", "~> 2.3"  # For policy-based authorization

# llm and ai related gems
gem "ruby-openai", "~> 8.0.0"
gem "langchain"
gem "tokenizers"
gem "redis", ">= 4.0.1"
gem "sidekiq"

# api related
gem "jsonapi-serializer"
gem "oj"

# active storage
gem "aws-sdk-s3", require: false

# API documentation
gem "rswag-api"
gem "rswag-ui"
gem "rswag-specs", group: [ :development, :test ]

# colorized output for rake tasks and console colors
gem "rainbow", "~> 3.1.1"

# Logging and monitoring
gem "semantic_logger", "~> 4.15"  # Structured logging with JSON support
gem "rails_semantic_logger", "~> 4.15"  # Rails integration for semantic_logger
gem "lograge", "~> 0.14.0"       # Request logging in JSON format
gem "http_logger", "~> 1.0"      # HTTP request logging
gem "rack-cache", "~> 1.14.0"
gem "request_store", "~> 1.5.1"
gem "responders"
gem "rubocop", "~> 1.62", require: false

# Security-related gems
# gem "devise", "~> 4.9"           # Authentication
gem "cancancan", "~> 3.5"        # Authorization
gem "rack-attack", "~> 6.7"      # Rate limiting
gem "secure_headers", "~> 6.5"   # Security headers
# gem "bcrypt", "~> 3.1"           # Password hashing
gem "jwt", "~> 2.7"              # JSON Web Tokens

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 6.0", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # api documentation dependencies for development
  # gem "rspec-rails"

  # load environment variables from .env file
  # Using plain dotenv for Rails 8 compatibility, not dotenv-rails
  gem "dotenv", "~> 2.8.1"

  # test coverage reporting
  # gem "simplecov", require: false

  # testing gems
  gem "cucumber"
  gem "cucumber-rails", require: false
  gem "database_cleaner-active_record"
  gem "vcr"
  gem "webmock"
  gem "shoulda-matchers"

  # N+1 query detection and prevention
  gem "n1_loader"    # Modern N+1 prevention, especially good for GraphQL

  # security auditing
  gem "ruby_audit"

  # OpenAPI parser
  gem "openapi_parser"

  # Existing test gems...
  gem "mock_redis"

  # Dependency vulnerability scanner
  gem "bundle-audit", "~> 0.1.0", require: false
end

# aws services
gem "aws-sdk-ssm", "~> 1.0"

# ai integration
# Commenting out due to ARM compatibility issues in Docker builds
# gem "llama_cpp"  # Local LLM integration

gem "makara", "~> 0.5.1"

gem "sqlite3", "~> 2.6"

gem "active_storage_validations"

# Gems in alphabetical order
gem "active_model_serializers", "~> 0.10.0"
gem "activestorage-validator"

# Testing
group :test do
  # Use RSpec for testing
  gem "rspec-rails", "~> 6.1.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "simplecov", "~> 0.22.0", require: false
  gem "test-unit", "~> 3.6.1", require: false  # Required for minitest support
end
