FROM ubuntu:16.04

MAINTAINER Carlos Salguero <carlos.salguero@percona.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/home/testuser/golang/bin/" \
    GOPATH="/home/testuser/golang" \
    PERCONA_TOOLKIT_SANDBOX="/tmp/mysql" \
    PERCONA_TOOLKIT_BRANCH="/home/testuser/golang/src/github.com/percona/percona-toolkit" \
    PERCONA_SLOW_BOX=1 \
    PERL5LIB="${GOPATH}/src/github.com/percona/percona-toolkit/lib" \

RUN ls -la
ADD https://storage.googleapis.com/golang/go1.9beta2.linux-amd64.tar.gz /tmp/go1.9beta2.linux-amd64.tar.gz

RUN apt update && \
    apt install -y git libdbi-perl libdbd-mysql-perl libdbd-mysql libaio1 libaio-dev build-essential && \
# Install Perl dependencies
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install JSON' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'Net::Address::IP::Local' && \
# We don't want to run everything as root
    adduser --disabled-password --gecos '' testuser && \
# Install Go
    tar -C /usr/local -xzf /tmp/go1.9beta2.linux-amd64.tar.gz && \
# Install Go dependencies manager (glide) & clone Percona Toolkit repo
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide && \
# Set owner & permissions sin previous step were run as root
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clone the Toolkit repo
    git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \

# Check if env is setup
    cd /home/testuser/golang/src/github.com/percona/percona-toolkit && perl util/check-dev-env && \
# Clean up
    apt autoremove && \
    apt autoclean -y && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries
    mkdir -p /tmp/mysql && \
    chmod -R 777 /tmp

USER testuser
ADD run.sh /home/testuser/run.sh

WORKDIR /home/testuser

ENTRYPOINT ["/home/testuser/run.sh"]
