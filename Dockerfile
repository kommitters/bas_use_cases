# Use the official Ruby image from the Docker Hub
FROM ruby:3.3.3-bullseye

ENV GEM_HOME="/usr/local/bundle"
ENV GEM_PATH="/usr/local/bundle"

ARG BUNDLE_GITHUB__COM
ENV BUNDLE_GITHUB__COM=${BUNDLE_GITHUB__COM}

# Install cron
RUN apt-get update && apt-get install -y cron build-essential libffi-dev

# We prepare the app directory for the project base
WORKDIR /app
COPY . .

RUN bundle install
