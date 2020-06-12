FROM ruby:2.6

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --no-deployment
COPY . /app
RUN chmod 755 startup.sh

EXPOSE 8080
ENV PORT 8080

ENTRYPOINT ["/app/startup.sh"]