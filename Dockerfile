FROM ruby:2.6.2

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - ;\
    apt-get update -qq && apt-get install -y nodejs

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - ;\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list ;\
    apt-get update -qq && apt-get install -y yarn

# Bundler
RUN gem install bundler

# Seeding base Rails gems to speed template execution
COPY Gemfile.seed Gemfile
RUN bundle install
RUN rm Gemfile Gemfile.lock

# Setup project directory
RUN mkdir /myapp
WORKDIR /myapp
COPY . .

ENV YARN_CACHE_FOLDER=/myapp/tmp/yarn-cache

CMD ["rails", "new", "example-app", "--skip-coffee", "--webpack", "-d", "postgresql", "-T", "-m", "template.rb"]
