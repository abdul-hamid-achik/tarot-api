# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for ARM architecture (M1/M2/M3/M4) only
# Build with: docker build -t tarot_api .
# Run with: docker run -d -p 3000:3000 -e RAILS_MASTER_KEY=<value from config/master.key> --name tarot_api tarot_api

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
FROM ruby:3.4-slim-bookworm AS base

# Verify ARM architecture
RUN arch=$(uname -m) && \
    if [[ "$arch" != arm* ]] && [[ "$arch" != aarch64 ]]; then \
      echo "This Dockerfile only supports ARM architecture (got $arch)" && \
      exit 1; \
    fi

# install essential packages
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    pkg-config \
    libyaml-dev \
    curl \
    cmake \
    wget && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# set workdir
WORKDIR /app

# development stage
FROM base AS development

# install development gems before copying application code
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# copy application code
COPY . .

# configure for development
ENV RAILS_ENV=development \
    RAILS_LOG_TO_STDOUT=true \
    # Connection pool configuration
    RAILS_MAX_THREADS=5 \
    WEB_CONCURRENCY=2 \
    # Makara replica configuration
    DB_REPLICA_ENABLED=false \
    DB_POOL_SIZE=10 \
    # Redis connection pools
    REDIS_POOL_SIZE=15 \
    REDIS_TIMEOUT=2 \
    # Health check credentials
    HEALTH_CHECK_USERNAME=admin \
    HEALTH_CHECK_PASSWORD=tarot_health_check

# health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# builder stage for production
FROM base AS builder

# install gems for production
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local frozen false && \
    bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ /usr/local/bundle/cache

# copy application code
COPY . .

# precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# production stage
FROM ruby:3.4-slim-bookworm AS production

# Verify ARM architecture
RUN arch=$(uname -m) && \
    if [[ "$arch" != arm* ]] && [[ "$arch" != aarch64 ]]; then \
      echo "This Dockerfile only supports ARM architecture (got $arch)" && \
      exit 1; \
    fi

# install runtime dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    libpq-dev \
    libyaml-dev \
    curl \
    wget && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# set workdir
WORKDIR /app

# Set environment variables
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    # Connection pool configuration - more conservative
    RAILS_MAX_THREADS=10 \
    WEB_CONCURRENCY=5 \
    # Makara replica configuration - override these in production
    DB_REPLICA_ENABLED=true \
    DB_PRIMARY_HOST=db-primary \
    DB_PRIMARY_USER=postgres \
    DB_PRIMARY_PORT=5432 \
    DB_REPLICA_HOST=db-replica \
    DB_REPLICA_USER=postgres \
    DB_REPLICA_PORT=5432 \
    DB_POOL_SIZE=20 \
    DB_POOL_TIMEOUT=5 \
    DB_REAPING_FREQUENCY=10 \
    # Redis connection pools
    REDIS_POOL_SIZE=30 \
    REDIS_TIMEOUT=3 

# copy from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# add non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /app

USER rails

# health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000
# Startup command with an initial connection pool check
CMD ["sh", "-c", "bundle exec rake db:pool:healthcheck && bundle exec rails server -b 0.0.0.0"]
