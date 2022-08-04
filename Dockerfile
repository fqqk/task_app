FROM ruby:2.6.3

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.lis \
  && apt-get update -qq && apt-get install -y build-essential nodejs npm yarn postgresql-client chromium-driver

WORKDIR /task_app
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
RUN gem install bundler -v 1.17.2
RUN bundle install
RUN npm install yarn -g --force
COPY . /task_app
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080
CMD ["rails", "server", "-b", "0.0.0.0"]