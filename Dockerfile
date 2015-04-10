# SkyStore-Web-CI
FROM jenkins
USER root

# Enviroment variables
ENV NODE_VERSION 0.12.2
ENV INSTALL_RUBY_VERSION 2.1.0
ENV CONFIGURE_OPTS --disable-install-doc

# Update container
RUN apt-get update -qq && apt-get install -y build-essential

# Add SSH key
RUN mkdir /var/jenkins_home/.ssh/

# Copy over private key, and set permissions
COPY id_rsa /var/jenkins_home/.ssh/id_rsa
COPY id_rsa.pub /var/jenkins_home/.ssh/id_rsa.pub

# Add internal repository to known_hosts
CMD ssh-keyscan -H git.bskyb.com >> ~/.ssh/known_hosts
CMD ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Add Jenkins plugings
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

# Install nodejs
RUN curl -SLO "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && npm install -g npm@"$NPM_VERSION" \
  && npm cache clear

# Install bower as global npm package
RUN npm install bower -g

# Install ruby
RUN apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev git
ADD http://cache.ruby-lang.org/pub/ruby/2.1/ruby-$INSTALL_RUBY_VERSION.tar.gz /tmp/

RUN cd /tmp && \
    tar -xzf ruby-$INSTALL_RUBY_VERSION.tar.gz && \
    cd ruby-$INSTALL_RUBY_VERSION && \
    ./configure && \
    make && \
    make install $CONFIGURE_OPTS && \
    cd .. && \
    rm -rf ruby-$INSTALL_RUBY_VERSION && \
    rm -f ruby-$INSTALL_RUBY_VERSION.tar.gz

# Install bundler gem
RUN gem install bundler --no-ri --no-rdoc

# Install gem needed for project
COPY Gemfile /usr/share/Gemfile
RUN cd /usr/share/ && bundler install 

USER jenkins