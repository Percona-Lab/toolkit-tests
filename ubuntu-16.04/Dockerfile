FROM ubuntu:16.04

MAINTAINER Carlos Salguero <carlos.salguero@percona.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/home/testuser/golang/bin/" \
    GOPATH="/home/testuser/golang" \
    PERCONA_TOOLKIT_SANDBOX="/mysql" \
    PERCONA_TOOLKIT_BRANCH="/home/testuser/golang/src/github.com/percona/percona-toolkit" \
    PERCONA_SLOW_BOX=1


ADD https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz /tmp/go.linux-amd64.tar.gz

RUN apt update && \
    apt install -y git libdbi-perl libdbd-mysql-perl libdbd-mysql libaio1 libaio-dev build-essential libnuma1 && \
# Install Perl dependencies
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install JSON' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'Net::Address::IP::Local' && \
# We don't want to run everything as root
    adduser --disabled-password --gecos '' testuser && \
# Install Go
    tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz && \
# Install Go dependencies manager (glide) & clone Percona Toolkit repo
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide && \
# Set owner & permissions sin previous step were run as root
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clone the Toolkit repo
    git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \
# Clean up
    apt autoremove && \
    apt autoclean -y && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries
    mkdir -p /mysql && \
    chmod -R 777 /tmp

USER testuser
ADD run.sh /home/testuser/run.sh

WORKDIR /home/testuser

VOLUME [ "/mysql", "/tmp" ]

ENTRYPOINT ["/home/testuser/run.sh"]
