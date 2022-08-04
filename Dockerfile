# syntax=docker/dockerfile:1
FROM ruby:2.7.5-slim-buster
RUN apt-get update -qq && apt-get install -y nodejs npm libpq-dev postgresql-client
WORKDIR /ttt_pd
COPY Gemfile /ttt_pd/Gemfile
COPY Gemfile.lock /ttt_pd/Gemfile.lock
RUN npm install -g yarn
RUN bundle install
RUN bundle exec rails webpacker:install
RUN bundle exec rails db:setup db:migarte db:seed

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
