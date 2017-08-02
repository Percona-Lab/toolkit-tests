#!/bin/bash

mkdir -p ${HOME}/mysql
cd ${HOME}/mysql 

rm -f get_download_link.sh
wget https://raw.githubusercontent.com/Percona-QA/percona-qa/master/get_download_link.sh > /dev/null 2>&1 && chmod +x get_download_link.sh

declare -A files

files=(\
# Percona server
    ["ps-5.7-debian"]="$(./get_download_link.sh --product=ps --version=5.7 --arch=x86_64 --type=prod --distribution=ubuntu)" \
    ["ps-5.6-debian"]="$(./get_download_link.sh --product=ps --version=5.6 --arch=x86_64 --type=prod --distribution=ubuntu)" \
    ["ps-5.5-debian"]="$(./get_download_link.sh --product=ps --version=5.5 --arch=x86_64 --type=prod --distribution=ubuntu)" \
    ["ps-5.7-centos"]="$(./get_download_link.sh --product=ps --version=5.7 --arch=x86_64 --type=prod --distribution=centos)" \
    ["ps-5.6-centos"]="$(./get_download_link.sh --product=ps --version=5.6 --arch=x86_64 --type=prod --distribution=centos)" \
    ["ps-5.5-centos"]="$(./get_download_link.sh --product=ps --version=5.5 --arch=x86_64 --type=prod --distribution=centos)" \
# MySQL server
    ["my-5.7"]="$(./get_download_link.sh --product=mysql --version=5.7 --arch=x86_64 --type=prod)" \
    ["my-5.6"]="$(./get_download_link.sh --product=mysql --version=5.6 --arch=x86_64 --type=prod)" \
    ["my-5.5"]="$(./get_download_link.sh --product=mysql --version=5.5 --arch=x86_64 --type=prod)" \
    ["my-8.0"]="$(./get_download_link.sh --product=mysql --version=8.0 --arch=x86_64 --type=prod)" \
# MariaDB
    ["mdb-10.2"]="$(./get_download_link.sh --product=mariadb --version=10.2 --arch=x86_64 --type=prod)" \
    ["mdb-10.1"]="$(./get_download_link.sh --product=mariadb --version=10.1 --arch=x86_64 --type=prod)" \
    ["mdb-10.0"]="$(./get_download_link.sh --product=mariadb --version=10.0 --arch=x86_64 --type=prod)" \
# Percona XtraDB Cluster
    ["pxc-5.7-debian"]="$(./get_download_link.sh --product=pxc --version=5.7 --arch=x86_64 --type=prod --distribution=ubuntu)" \
    ["pxc-5.6-debian"]="$(./get_download_link.sh --product=pxc --version=5.6 --arch=x86_64 --type=prod --distribution=ubuntu)" \
    ["pxc-5.7-centos"]="$(./get_download_link.sh --product=pxc --version=5.7 --arch=x86_64 --type=prod --distribution=centos)" \
    ["pxc-5.6-centos"]="$(./get_download_link.sh --product=pxc --version=5.6 --arch=x86_64 --type=prod --distribution=centos)" \
    ["pxc-5.5"]="$(./get_download_link.sh --product=pxc --version=5.5 --arch=x86_64 --type=prod)" \
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

