FROM centos:7

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/home/testuser/golang/bin/:/root/perl5/bin:/mysql/bin" \
    GOPATH="/home/testuser/golang" \
    PERCONA_TOOLKIT_SANDBOX="/mysql" \
    PERCONA_TOOLKIT_BRANCH="/home/testuser/golang/src/github.com/percona/percona-toolkit" \
    PERCONA_SLOW_BOX=1 \
    PERL_LOCAL_LIB_ROOT="$PERL_LOCAL_LIB_ROOT:/root/perl5" \
    PERL_MB_OPT="--install_base /root/perl5" \
    PERL_MM_OPT="INSTALL_BASE=/root/perl5" \
    PERL5LIB="/root/perl5/lib/perl5:$PERL5LIB" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8

ADD https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz /tmp/go.linux-amd64.tar.gz

RUN yum clean all && \
    yum check && \
    yum erase apf && \
    yum upgrade -y && \
    yum install -y deltarpm && \
    yum groupinstall -y 'Development Tools' && \
    yum install -y git perl-devel perl-core perl-CPAN perl-DBI perl-DBD-MySQL libdbi-dbd-mysql libaio libaio-devel numactl-libs vim locales libjemalloc && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    /usr/bin/git config --global diff.tool vimdiff && \
    /usr/bin/git config --global alias.d difftool && \
# Install Perl dependencies && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install File::Slurp' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install JSON' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Net::Address::IP::Local' && \
    PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Text::Diff' && \
# We don't want to run everything as root && \
    useradd -ms /bin/bash testuser && \
# Install Go && \
    tar -C /usr/local -xzf /tmp/go.linux-amd64.tar.gz && \
# Set owner & permissions sin previous step were run as root && \
    chown -R testuser /home/testuser && \
    chmod -R 777 /home/testuser && \
# Clone the Toolkit repo && \
# Clean up && \
    yum clean all && \
    rm -rf /tmp/* && \
# In this directory we will mount the directory having the MySQL binaries && \
    mkdir -p /mysql && \
    chmod -R 777 /tmp

USER testuser
ADD run.sh /home/testuser/run.sh
ADD my.cnf /home/testuser/.my.cnf

RUN git clone https://github.com/percona/percona-toolkit.git /home/testuser/golang/src/github.com/percona/percona-toolkit && \
# Install Go dependencies manager (glide) & clone Percona Toolkit repo && \
    go get github.com/Masterminds/glide && \
    go install github.com/Masterminds/glide 

USER root
RUN /bin/ln -s /home/testuser/golang/src/github.com/percona/percona-toolkit/util/mysql_random_data_load /usr/local/bin/ && \
    chmod 600 /home/testuser/.my.cnf
USER testuser

WORKDIR /home/testuser

VOLUME [ "/mysql", "/tmp" ]

ENTRYPOINT ["/home/testuser/run.sh"]
