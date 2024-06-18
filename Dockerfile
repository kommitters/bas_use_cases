# Use the official Ruby image from the Docker Hub
FROM ruby:latest

# Install cron
RUN apt-get update && apt-get install -y cron

# We prepare the app directory for the project base
WORKDIR /app
COPY . .
