FROM golang:1.8.3

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential curl git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev python-yaml python-jinja2 python-httplib2 python-keyczar python-paramiko python-setuptools python-pkg-resources python-pip

# Install ansible 
RUN mkdir /etc/ansible/
RUN echo '[local]\nlocalhost\n' > /etc/ansible/hosts
RUN mkdir /opt/ansible/
RUN git clone http://github.com/ansible/ansible.git /opt/ansible/ansible
WORKDIR /opt/ansible/ansible
RUN git submodule update --init
ENV PATH /opt/ansible/ansible/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV PYTHONPATH /opt/ansible/ansible/lib
ENV ANSIBLE_LIBRARY /opt/ansible/ansible/library

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
RUN xargs -L 1 rbenv install 2.3.4

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN rbenv global 2.3.4
RUN rbenv exec gem install bundler
RUN rbenv exec gem i rbenv-rehash

# Setup Docker Client
ENV DOCKER_CLIENT_VERSION=17.03.0-ce
RUN set -x
RUN mkdir /docker_client_cache -m 755
RUN curl -L -o /docker_client_cache/docker-$DOCKER_CLIENT_VERSION.tgz https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_CLIENT_VERSION.tgz
RUN tar -xz -C /tmp -f /docker_client_cache/docker-$DOCKER_CLIENT_VERSION.tgz
RUN mv /tmp/docker/* /usr/bin

RUN pip install awscli
