FROM ruby:3.2.2-slim

# Install required packages
RUN apt-get update -qq && \
    apt-get install -y build-essential git libpq-dev libvips nodejs postgresql-client

WORKDIR /rails

# Copy Gemfile and Gemfile.lock from your build context (they should be in your server/ folder)
COPY Gemfile Gemfile.lock ./

# Install gems in the default location (/usr/local/bundle)
RUN bundle install

# Copy the rest of your Rails app
COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]