FROM ubuntu:14.04

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/home/testuser/golang/bin/:/mysql/bin" \
    GOPATH="/home/testuser/golang" \
    PERCONA_TOOLKIT_SANDBOX="/mysql" \
    PERCONA_TOOLKIT_BRANCH="/home/testuser/golang/src/github.com/percona/percona-toolkit" \
    PERCONA_SLOW_BOX=1 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8

ADD https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz /tmp/go.linux-amd64.tar.gz

RUN apt-get update && \
    apt-get install -y git libdbi-perl libdbd-mysql-perl libdbd-mysql libaio1 libaio-dev build-essential libnuma1 vim locales jemalloc1 && \
    locale-gen en_US en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/bin/git config --global diff.tool vimdiff && \
    /usr/bin/git config --global alias.d difftool && \
# Install Perl dependencies
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install JSON' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Address::IP::Local' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Text::Diff' && \
# We don't want to run everything as root
    adduser --disabled-password --gecos '' testuser && \
# Install Go
    tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz && \
# Set owner & permissions sin previous step were run as root
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clean up
    apt-get autoremove && \
    apt-get autoclean -y && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries
    mkdir -p /mysql && \
    chmod -R 777 /tmp

USER testuser
ADD run.sh /home/testuser/run.sh
ADD my.cnf /home/testuser/.my.cnf

# Clone the Toolkit repo
RUN git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \
# Install Go dependencies manager (glide) & clone Percona Toolkit repo
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide 

USER root
RUN /bin/ln -s /home/testuser/golang/src/github.com/percona/percona-toolkit/util/mysql_random_data_load /usr/local/bin/ && \
    chmod 600 /home/testuser/.my.cnf
USER testuser

WORKDIR /home/testuser

VOLUME [ "/mysql", "/tmp" ]

ENTRYPOINT ["/home/testuser/run.sh"]
