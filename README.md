# Percona Toolkit tests
## Docker container to run Percona Toolkit tests

The idea for this container is to be able to run Percona Toolkit tests wile working on a different branch.  
To run the tests, you will need MySQL binaries in your local computer and mount the directory containing the MySQL version you want to use for testing.  

You can use the script `download_mysql.sh` to automatically download all MySQL versions currently used for testing. The script will create a new `mysql` directory inside your home and it will download and prepare this MySQL versions:

Percona server: `5.7.18`, `5.6.36`, `5.5.55`  
MySQL server: `5.7.18`, `5.6.36`, `5.5.56`, `8.0.1`  
MariaDB: `10.2.7`, `10.1.25`, `10.0.31`  
Percona XtraDB Cluster: `5.7.18`, `5.6.36`, `5.5.41`  

After running the script, you will have these directories at `${HOME}/mysql`:  
```
tree ${HOME}/mysql -d -L 1
.
├── mdb-10.0.31
├── mdb-10.1.25
├── mdb-10.2.7
├── my-5.5.56
├── my-5.6.36
├── my-5.7.18
├── my-8.0.1
├── ps-5.5.55
├── ps-5.6.36
├── ps-5.7.18
├── pxc-5.5.41
├── pxc-5.6.36
└── pxc-5.7.18
```

### Building the image

Just build it as any other image: `docker build --tag=toolkit-test .`  

### Running tests 

The cli parameters to run tests is this:  
`docker run --rm -v <path_to_mysql_version>:/tmp/mysql toolkit-test [branch name] [test file]`  

`[branch name]` is the remote branch you want to test. **Default: 3.0**  
`[test file]` is the test file in case you want to run only one specific test. If it was not specified, it will assume all tests in the `t` directory (`t/*`)

For the examples I'll assume you have downloaded all MySQL versions using the `download_mysql.sh` script.  

#### Examples:  
1) Running all tests for the **3.0** branch using **MySQL 5.7.18**:  
```
docker run --rm -v ${HOME}/mysql/my-5.7.18:/tmp/mysql toolkit-test
```  
  
2) Running all tests for the **PT-91-MySQL-5.7** branch using **Percona Server 5.7.18**:  
```
docker run --rm -v ${HOME}/mysql/ps-5.7.18:/tmp/mysql toolkit-test PT-91-MySQL-5.7
```

3) Running only tests in the **t/pt-online-schema-change/** directory, for the **PT-91-MySQL-5.7** branch, using **MySQL 5.7.18**:  
```
docker run --rm ${HOME}/mysql/my-5.7.18:/tmp/mysql toolkit-test PT-91-MySQL-5.7 t/pt-online-schema-change/*
```

4) Running only the tests in `t/pt-online-schema-change/preserve-triggers.t`, for the **PT-91-MySQL-5.7** branch, using **MySQL 5.7.18**:  
```
docker run --rm ${HOME}/mysql/my-5.7.18:/tmp/mysql toolkit-test PT-91-MySQL-5.7 t/pt-online-schema-change/preserve-triggers.t
```

5) Running tests for **MariaDB**:
In this case we need to specify the `FORK` variable to let the sandbox know we are not using a fork. (Percona server doesn't need this variable since it is a drop-in replacement of MySQL)
```
docker run --rm -e "FORK=mariadb" -v ${HOME}/mysql/mdb-10.2.7:/tmp/mysql toolkit-test
```
  
  
**Notes**  
1) In these examples I am using the `--rm` because I don't need to keep the container.  
2) You can redirect the output to a file to capture the logs for further analysis.
