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

This script will make MySQL *barebones* resulting in much smaller directories having only the necessary files to start MySQL and run the Toolkit tests.  

```
Regular MySQL files disk usage                     Disk usage as barebones

   du -ch -d 4 | sort -k 2                         du -ch -d 1 | sort -k 2  
   892M    ./mdb-10.0.31                           124M    ./mdb-10.0.31    
   1,4G    ./mdb-10.1.25                           133M    ./mdb-10.1.25    
   1,6G    ./mdb-10.2.7                            163M    ./mdb-10.2.7     
   597M    ./my-5.5.56                             79M     ./my-5.5.56      
   915M    ./my-5.6.36                             114M    ./my-5.6.36      
   1,3G    ./my-5.7.18                             290M    ./my-5.7.18      
   1,3G    ./my-8.0.1                              422M    ./my-8.0.1       
   210M    ./ps-5.5.55                             86M     ./ps-5.5.55      
   738M    ./ps-5.6.36                             125M    ./ps-5.6.36      
   600M    ./ps-5.7.18                             63M     ./ps-5.7.18      
   481M    ./pxc-5.5.41                            107M    ./pxc-5.5.41     
   341M    ./pxc-5.6.36                            161M    ./pxc-5.6.36     
   1,2G    ./pxc-5.7.18                            316M    ./pxc-5.7.18     
   12G     total                                   2,2G    total            

```
  
### Building the image

Just build it as any other image: `docker build --tag=toolkit-test .`  

### Mount points
There are 2 mount points avaible in the containters:  
`/mysql`: Directory having MySQL binaries (**Mandatory**) *See examples below*  
`/tmp`: Linux temporary directory. This mount point can be used to mount the `/tmp` directory into a [tmpfs](http://manpages.ubuntu.com/manpages/zesty/man5/tmpfs.5.html). Using `tmps` will drastically increase the testing speed since all database creation/load/drop will happen in memory.  

#### Try /tmp on tmpfs                                 
To mount `/tmp` on `tmps` simply run these commands:  
```
echo "tmpfs /tmp tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab
sudo reboot
```

### Running tests 

The cli parameters to run tests is this:  
`docker run --rm -ti -v <path_to_mysql_version>:/mysql toolkit-test [repo url] [branch name] [test file]`  

`[repo url]` is the remote repository having the branch you want to test. **Default: origin**  
`[branch name]` is the remote branch you want to test. **Default: 3.0**  
`[test file]` is the test file in case you want to run only one specific test. If it was not specified, it will assume all tests in the `t` directory (`t/*`)

For the examples I'll assume you have downloaded all MySQL versions using the `download_mysql.sh` script.  

#### Examples:  
1) Running all tests for the **3.0** branch using **MySQL 5.7.18**:  
```
docker run --rm -ti -v ${HOME}/mysql/my-5.7.18:/mysql toolkit-test
```  
  
2) Running all tests for the **PT-91-MySQL-5.7** branch using **Percona Server 5.7.18**:  
```
docker run --rm -ti -v ${HOME}/mysql/ps-5.7.18:/mysql toolkit-test origin PT-91-MySQL-5.7
```

3) Running all tests for the **test-branch** branch from a fork:  
```
docker run --rm -ti -v ${HOME}/mysql/ps-5.7.18:/mysql toolkit-test https://github.com/some_fork_name/percona-toolkit.git test-branch
```

4) Running only tests in the **t/pt-online-schema-change/** directory, for the **PT-91-MySQL-5.7** branch, using **MySQL 5.7.18**:  
```
docker run --rm -ti ${HOME}/mysql/my-5.7.18:/mysql toolkit-test origin PT-91-MySQL-5.7 t/pt-online-schema-change/*
```

5) Running only the tests in `t/pt-online-schema-change/preserve-triggers.t`, for the **PT-91-MySQL-5.7** branch, using **MySQL 5.7.18**:  
```
docker run --rm -ti ${HOME}/mysql/my-5.7.18:/mysql toolkit-test origin PT-91-MySQL-5.7 t/pt-online-schema-change/preserve-triggers.t
```

6) Running tests for **MariaDB**:
In this case we need to specify the `FORK` variable to let the sandbox know we are not using a fork. (Percona server doesn't need this variable since it is a drop-in replacement of MySQL)
```
docker run --rm -ti -e "FORK=mariadb" -v ${HOME}/mysql/mdb-10.2.7:/mysql toolkit-test
```
  
7) Using `tmpfs`:
   In case your `/tmp` directory is mounted on a `tmpfs`, you can set up a directory from your host, to be used by the container.  Example:

```
mkdir /tmp/toolkit-test-tmp
docker run --rm -ti -v ${HOME}/mysql/my-5.7.18:/mysql -v /tmp/toolkit-test-tmp:/tmp toolkit-test
```
This will mount the directory `/tmp/toolkit-test-tmp` from the host into `/tmp` inside the container.  
Since your local's `/tmp` is mouted on a *tmpfs*, `/tmp` in the cotainer will also be mounted on the *tmpfs* so, all operations on the testing databases will run much faster.  

  
**Notes**  
1) In these examples I am using the `--rm` because I don't need to keep the container.  
2) You can redirect the output to a file to capture the logs for further analysis.
3) -ti is not mandatory,  but it will allow you to use CTRL+C to stop the tests
