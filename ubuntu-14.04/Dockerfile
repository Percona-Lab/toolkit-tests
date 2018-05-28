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

RUN apt update && \
    apt install -y git libdbi-perl libdbd-mysql-perl libdbd-mysql libaio1 libaio-dev build-essential libnuma1 libjson-perl vim locales libjemalloc1 && \
    echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale && \
    locale-gen && \
    /usr/bin/git config --global diff.tool vimdiff && \
    /usr/bin/git config --global alias.d difftool && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Address::IP::Local' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Text::Diff' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'force install DBI' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'force install DBD::mysql' && \
    PERL_MM_USE_DEFAULT=1 cpan -T -f JSON && \
    adduser --disabled-password --gecos '' testuser && \
    tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz && \
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide && \
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clean up
#    apt autoremove && \
#    apt autoclean -y && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries
    mkdir -p /mysql && \
    chmod -R 777 /tmp 

USER testuser
ADD --chown=testuser run.sh /home/testuser/run.sh
ADD --chown=testuser my.cnf /home/testuser/.my.cnf
ADD --chown=testuser bashrc /home/testuser/.bashrc

# Install Go dependencies manager (glide) & clone Percona Toolkit repo && 
RUN git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide 

USER root

RUN /bin/ln -s /home/testuser/golang/src/github.com/percona/percona-toolkit/util/mysql_random_data_load /usr/local/bin/ && \
    chmod 600 /home/testuser/.my.cnf && \
    chmod 777 /home/testuser/.bashrc

USER testuser

WORKDIR /home/testuser

VOLUME [ "/mysql", "/tmp" ]

ENTRYPOINT ["/home/testuser/run.sh"]
