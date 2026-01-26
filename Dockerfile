FROM ruby:3.3.3-bullseye

RUN apt-get update && apt-get install -y \
    cron \
    build-essential \
    libffi-dev \
    lsb-release \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install sinatra rackup puma

RUN install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail \
    https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

RUN apt-get update && apt-get install -y postgresql-client-16 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Match lockfile bundler version to avoid auto-install each build
RUN gem install bundler -v 2.6.8

# Bundler config for consistent gem path (helps caching/stability)
RUN bundle config set path '/usr/local/bundle'

# Copy only gemfiles first so bundle install is cacheable
COPY Gemfile Gemfile.lock ./

RUN bundle install

# Copy the rest of the project
COPY . .
