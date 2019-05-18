FROM ruby:2.6

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update -qq && apt-get install -y nodejs
RUN gem install rake bundler rails

# seeding base Rails gems to speed template execution
COPY Gemfile.seed Gemfile
RUN bundler install
RUN rm Gemfile

WORKDIR /myapp
VOLUME /myapp
CMD ["rails", "new", "test-rails-app", "--skip-coffee", "--webpack", "-d", "postgresql", "-T", "-m", "template.rb"]
