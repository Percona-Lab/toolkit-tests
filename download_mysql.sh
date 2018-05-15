#!/bin/bash

SCRIPT_PWD=$(cd `dirname $0` && pwd)

mkdir -p ${HOME}/mysql
cd ${HOME}/mysql 

#rm -f get_download_link.sh
#wget https://raw.githubusercontent.com/Percona-QA/percona-qa/master/get_download_link.sh > /dev/null 2>&1 && chmod +x get_download_link.sh

declare -A files

files=(\
# Percona server
    ["ps-5.7-debian"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.7 --arch=x86_64 --distribution=ubuntu)" \
    ["ps-5.6-debian"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.6 --arch=x86_64 --distribution=ubuntu)" \
    ["ps-5.7-debian-ssl102"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.7 --arch=x86_64 --distribution=ubuntu-bionic)" \
    ["ps-5.6-debian-ssl102"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.6 --arch=x86_64 --distribution=ubuntu-bionic)" \
    ["ps-5.5-debian"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.5 --arch=x86_64 --distribution=ubuntu)" \
#    ["ps-5.7-centos"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.7 --arch=x86_64 --distribution=centos)" \
#    ["ps-5.6-centos"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.6 --arch=x86_64 --distribution=centos)" \
#    ["ps-5.5-centos"]="$(${SCRIPT_PWD}/get_download_link.sh --product=ps --version=5.5 --arch=x86_64 --distribution=centos)" \
# MySQL server
    ["my-5.7"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mysql --version=5.7 --arch=x86_64 )" \
    ["my-5.6"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mysql --version=5.6 --arch=x86_64 )" \
    ["my-5.5"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mysql --version=5.5 --arch=x86_64 )" \
    ["my-8.0"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mysql --version=8.0 --arch=x86_64 )" \
# MariaDB
    ["mdb-10.2"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mariadb --version=10.2 --arch=x86_64 )" \
    ["mdb-10.1"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mariadb --version=10.1 --arch=x86_64 )" \
    ["mdb-10.0"]="$(${SCRIPT_PWD}/get_download_link.sh --product=mariadb --version=10.0 --arch=x86_64 )" \
# Percona XtraDB Cluster
    ["pxc-5.7-debian"]="$(${SCRIPT_PWD}/get_download_link.sh --product=pxc --version=5.7 --arch=x86_64 --distribution=ubuntu)" \
    ["pxc-5.6-debian"]="$(${SCRIPT_PWD}/get_download_link.sh --product=pxc --version=5.6 --arch=x86_64 --distribution=ubuntu)" \
#    ["pxc-5.7-centos"]="$(${SCRIPT_PWD}/get_download_link.sh --product=pxc --version=5.7 --arch=x86_64 --distribution=centos)" \
#    ["pxc-5.6-centos"]="$(${SCRIPT_PWD}/get_download_link.sh --product=pxc --version=5.6 --arch=x86_64 --distribution=centos)" \
    ["pxc-5.5"]="$(${SCRIPT_PWD}/get_download_link.sh --product=pxc --version=5.5 --arch=x86_64 )" \
)

for abbrev in ${!files[@]}; do
    download_url=${files[$abbrev]} 
    tarfile=$(basename ${files[$abbrev]})
    original_dirname=${tarfile//\.tar\.gz/}
    new_dirname=${abbrev}

    if [ ! -d ${new_dirname} ]
    then
        if [ ! -f ${tarfile} ]
        then
            echo "Downloading ${abbrev}"
            wget ${download_url}
        else 
            echo "${tarfile} already exists. Skipping download"
        fi
        # This tar command is a copy from the make-barebones utility from the toolkit
        # It extracts only the minimum files required to run the toolkit tests.
        #tar xvzf ${tarfile} "$original_dirname/"
        #tar xvzf ${tarfile} \
        #    --ignore-failed-read \
        #    --ignore-command-error \
        #    --wildcards \
        tar xvzf ${tarfile} --wildcards "$original_dirname/COPYING*" \
        --wildcards "$original_dirname/README*" \
        --wildcards "$original_dirname/bin/clustercheck" \
        --wildcards "$original_dirname/bin/my_print_defaults" \
        --wildcards "$original_dirname/bin/mysql" \
        --wildcards "$original_dirname/bin/mysqladmin" \
        --wildcards "$original_dirname/bin/mysqlbinlog" \
        --wildcards "$original_dirname/bin/mysqld" \
        --wildcards "$original_dirname/bin/mysqld" \
        --wildcards "$original_dirname/bin/mysqld_safe" \
        --wildcards "$original_dirname/bin/mysqldump" \
        --wildcards "$original_dirname/bin/ps-admin" \
        --wildcards "$original_dirname/bin/resolveip" \
        --wildcards "$original_dirname/bin/safe_mysqld" \
        --wildcards "$original_dirname/bin/wsrep*" \
        --wildcards "$original_dirname/lib/*" \
        --wildcards "$original_dirname/scripts/mysql_install_db" \
        --wildcards "$original_dirname/share/*.sql" \
        --wildcards "$original_dirname/share/*.txt" \
        --wildcards "$original_dirname/share/charset*" \
        --wildcards "$original_dirname/share/english*" \
        --wildcards "$original_dirname/share/errmsg*" \
        --wildcards "$original_dirname/share/mysql/charset*" \
        --wildcards "$original_dirname/share/mysql/english*" \
        --wildcards "$original_dirname/share/mysql/errmsg*"
        # Rename it to its abbreviation. 
        # Example: the directory Percona-Server-5.7.18-15-Linux.x86_64.ssl100 will be renamed to ps-5.7.18
        mv ${original_dirname} ${new_dirname}
        # rm ${tarfile}
    else
        echo "Directory ${new_dirname} already exists. Skipping"
    fi
done

