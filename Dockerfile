# The recipe that builds the app into an image any server can run (Render reads this file).
# Same Ruby as the Gemfile, so production runs what we tested.
FROM ruby:3.4.11-slim

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT=1

WORKDIR /rails

# System packages: a compiler and libpq for the pg gem, Node + Yarn to build the JS and CSS
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev git curl nodejs npm && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Gems first: this layer is cached until the Gemfile changes, so rebuilds are fast
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install

# JS packages, for the same reason
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .

# Builds JS/CSS and fingerprints every asset. The key is a throwaway: this step only needs
# Rails to boot, and the real secret comes from the server's environment at run time.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

EXPOSE 10000
CMD ["bin/start-production"]
