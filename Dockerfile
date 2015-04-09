FROM jenkins
USER root

RUN apt-get update -qq && apt-get install -y build-essential

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV NODE_VERSION 0.12.2
ENV INSTALL_RUBY_VERSION 2.1.0
ENV CONFIGURE_OPTS --disable-install-doc

RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && npm install -g npm@"$NPM_VERSION" \
  && npm cache clear

RUN npm install bower -g

# install ruby, bundler
RUN apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev git

ADD http://cache.ruby-lang.org/pub/ruby/2.1/ruby-$INSTALL_RUBY_VERSION.tar.gz /tmp/

RUN cd /tmp && \
    tar -xzf ruby-$INSTALL_RUBY_VERSION.tar.gz && \
    cd ruby-$INSTALL_RUBY_VERSION && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf ruby-$INSTALL_RUBY_VERSION && \
    rm -f ruby-$INSTALL_RUBY_VERSION.tar.gz

RUN gem install bundler --no-ri --no-rdoc

COPY Gemfile /usr/share/Gemfile
RUN cd /usr/share/ && bundler install 

USER jenkins