# Use the official Ruby image from the Docker Hub
FROM ruby:3.3.3-bullseye

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    cron \
    build-essential \
    libffi-dev \
    lsb-release \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Sinatra
RUN gem install sinatra rackup puma

# Add PostgreSQL apt repository
RUN install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail \
    https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client-16 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up the working directory for the application
WORKDIR /app

# Copy the project files
COPY . .

# Install Ruby gems
RUN bundle install

