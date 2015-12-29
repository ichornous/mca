FROM ruby:2.2.0
MAINTAINER igor@chornous.com

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  mysql-client \
  nginx \
  vim \
  nodejs

COPY config/web.conf /etc/nginx/sites-enabled/default

ADD . /home/app

ENV HOME /home/app
ENV RAILS_ENV production
ENV SECRET_KEY_BASE $(openssl rand -base64 32)

WORKDIR /home/app

#
# Bundle install as root
#

RUN gem install bundler
RUN bundle install

EXPOSE 80

RUN bundle exec rake assets:precompile --trace
RUN bundle exec rake db:migrate --trace
RUN chgrp -R www-data $HOME/public
RUN find $HOME/public -type f -exec chmod g+r {} \;
RUN find $HOME/public -type d -exec chmod g+rx {} \;

CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile"]
