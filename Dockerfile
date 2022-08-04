# syntax=docker/dockerfile:1
FROM ruby:2.7.5-slim-buster
RUN apt-get update -qq && apt-get install -y nodejs npm libpq-dev postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN npm install -g yarn
RUN bundle install
RUN bundle exec rails webpacker:install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
