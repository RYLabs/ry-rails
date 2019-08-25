ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}-alpine

ARG BUNDLER_VERSION
ARG RAILS_VERSION

# Install system dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk update \
  && apk add --no-cache postgresql-client postgresql-dev nodejs \
    libffi-dev readline build-base libc-dev linux-headers \
    libxml2-dev libxslt-dev gcc tzdata less bash yarn git

# Bundler & Rails
RUN gem update --system \
    && gem install bundler:${BUNDLER_VERSION} \
    && gem install rails:${RAILS_VERSION}

# Setup Byebug
COPY .dockerdev/.byebugrc /root/.byebugrc

# Setup project directory
RUN mkdir /myapp
WORKDIR /myapp
