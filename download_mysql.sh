#!/bin/bash

mkdir -p ${HOME}/mysql
cd ${HOME}/mysql 

declare -A files

files=(\
# Percona server
    ["ps-5.7.18"]="https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-5.7.18-15/binary/tarball/Percona-Server-5.7.18-15-Linux.x86_64.ssl100.tar.gz" \
    ["ps-5.6.36"]="https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-5.6.36-82.0/binary/tarball/Percona-Server-5.6.36-rel82.0-Linux.x86_64.ssl100.tar.gz" \
    ["ps-5.5.55"]="https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.55-38.8/binary/tarball/Percona-Server-5.5.55-rel38.8-Linux.x86_64.ssl100.tar.gz" \
# MySQL server
    ["my-5.7.18"]="https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz" \
    ["my-5.6.36"]="https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz" \
    ["my-5.5.56"]="https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.56-linux-glibc2.5-x86_64.tar.gz" \
    ["my-8.0.1"]="https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.1-dmr-linux-glibc2.12-x86_64.tar.gz" \
# MariaDB
    ["mdb-10.2.7"]="http://mirror.upb.edu.co/mariadb//mariadb-10.2.7/bintar-linux-x86_64/mariadb-10.2.7-linux-x86_64.tar.gz" \
    ["mdb-10.1.25"]="http://mirror.upb.edu.co/mariadb//mariadb-10.1.25/bintar-linux-x86_64/mariadb-10.1.25-linux-x86_64.tar.gz" \
    ["mdb-10.0.31"]="http://mirror.upb.edu.co/mariadb//mariadb-10.0.31/bintar-linux-x86_64/mariadb-10.0.31-linux-x86_64.tar.gz" \
# Percona XtraDB Cluster
    ["pxc-5.7.18"]="https://www.percona.com/downloads/Percona-XtraDB-Cluster-LATEST/Percona-XtraDB-Cluster-5.7.18-29.20/binary/tarball/Percona-XtraDB-Cluster-5.7.18-rel15-29.20.1.Linux.x86_64.ssl100.tar.gz" \
    ["pxc-5.6.36"]="https://www.percona.com/downloads/Percona-XtraDB-Cluster-56/Percona-XtraDB-Cluster-5.6.36-26.20/binary/tarball/Percona-XtraDB-Cluster-5.6.36-rel82.0-26.20.1.Linux.x86_64.ssl100.tar.gz" \
    ["pxc-5.5.41"]="https://www.percona.com/downloads/Percona-XtraDB-Cluster-55/Percona-XtraDB-Cluster-5.5.41-25.12/binary/tarball/Percona-XtraDB-Cluster-5.5.41-rel37.0-25.11.853.Linux.x86_64.tar.gz" \
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
        tar xvzf ${tarfile} \
            --wildcards \
            "$original_dirname/COPYING" \
            "$original_dirname/README" \
            "$original_dirname/share/errmsg*" \
            "$original_dirname/share/charset*" \
            "$original_dirname/share/english*" \
            "$original_dirname/share/mysql/errmsg*" \
            "$original_dirname/share/mysql/charset*" \
            "$original_dirname/share/mysql/english*" \
            "$original_dirname/bin/my_print_defaults" \
            "$original_dirname/bin/mysql" \
            "$original_dirname/bin/mysqld" \
            "$original_dirname/bin/mysqladmin" \
            "$original_dirname/bin/mysqlbinlog" \
            "$original_dirname/bin/mysqldump" \
            "$original_dirname/bin/mysqld" \
            "$original_dirname/bin/mysqld_safe" \
            "$original_dirname/bin/safe_mysqld" \
            "$original_dirname/lib/libgalera_smm.so" \
            "$original_dirname/bin/clustercheck" \
            "$original_dirname/bin/wsrep*"
        # Rename it to its abbreviation. 
        # Example: the directory Percona-Server-5.7.18-15-Linux.x86_64.ssl100 will be renamed to ps-5.7.18
        mv ${original_dirname} ${new_dirname}
        rm ${tarfile}
    else
        echo "Directory ${new_dirname} already exists. Skipping"
    fi
done

