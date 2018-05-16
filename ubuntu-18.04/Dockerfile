FROM ubuntu:18.04

MAINTAINER Carlos Salguero <carlos.salguero@percona.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/home/testuser/golang/bin/" \
    GOPATH="/home/testuser/golang" \
    PERCONA_TOOLKIT_SANDBOX="/mysql" \
    PERCONA_TOOLKIT_BRANCH="/home/testuser/golang/src/github.com/percona/percona-toolkit" \
    PERCONA_SLOW_BOX=1


ADD https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz /tmp/go.linux-amd64.tar.gz

RUN apt update && \
    apt install -y git libdbi-perl libdbd-mysql-perl libdbd-mysql libaio1 libaio-dev build-essential libnuma1 libjson-perl && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Address::IP::Local' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Text::Diff' && \
    adduser --disabled-password --gecos '' testuser && \
    tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz && \
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide && \
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clean up
    apt autoremove && \
    apt autoclean -y && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries
    mkdir -p /mysql && \
    chmod -R 777 /tmp 

USER testuser
ADD run.sh /home/testuser/run.sh
# Install Go dependencies manager (glide) & clone Percona Toolkit repo && 
RUN git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide 
USER root
RUN /bin/ln -s /home/testuser/golang/src/github.com/percona/percona-toolkit/util/mysql_random_data_load /usr/local/bin/
USER testuser

WORKDIR /home/testuser

VOLUME [ "/mysql", "/tmp" ]

CMD ["/home/testuser/run.sh"]
