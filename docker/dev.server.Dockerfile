FROM ruby:3.2.2-slim

# Install required packages
RUN apt-get update -qq && \
    apt-get install -y build-essential git libpq-dev libvips nodejs postgresql-client netcat-traditional

WORKDIR /rails

# First copy just the Gemfile and Gemfile.lock
COPY server/Gemfile server/Gemfile.lock ./

# Debug: Show contents and location
RUN echo "=== Current Directory Contents ===" && \
    ls -la && \
    echo "=== Gemfile Contents ===" && \
    cat Gemfile && \
    echo "=== Bundler Version ===" && \
    bundle --version

# Clear any existing gems and install fresh with verbose output
RUN rm -rf /usr/local/bundle/* && \
    gem install bundler:2.6.3 && \
    echo "=== Bundler Config ===" && \
    bundle config && \
    bundle config set --local path '/usr/local/bundle' && \
    echo "=== Updated Bundler Config ===" && \
    bundle config && \
    echo "=== Starting Bundle Install ===" && \
    bundle install --jobs 4 --retry 3 --verbose

# Now copy the rest of the application
COPY server/ .

# Final debug check
RUN echo "=== Final Directory Structure ===" && \
    ls -R && \
    echo "=== Gem Environment ===" && \
    gem env && \
    echo "=== Bundle Environment ===" && \
    bundle env

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] 