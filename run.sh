#!/bin/bash

BRANCH=${1:-"3.0"}
TEST=${2:-"t/*"}

echo "Branch: $BRANCH"
echo "Tests: $TEST"

BASE_DIR='/home/testuser/golang/src/github.com/percona/percona-toolkit/'
cd $BASE_DIR

echo "Starting sandbox ..."
sandbox/test-env start
if [ $? -ne 0 ]; then
    echo 'Error: cannot start the sandbox'
    echo 'Plase check the directory containing the MySQL distribution you want to use'
    echo 'is mounted in /tmp/mysql'
    echo 'Example:'
    echo 'docker run --rm -v ${HOME}/mysql/mysql-5.5.56:/tmp/mysql toolkit-test [branch] [test file]'
    exit 1
fi

if [ -z "$BRANCH" ]; then
    echo "BRANCH variable is not set"
    exit 1
fi

git fetch origin
git branch -a | grep "/${BRANCH}$"

if [ $? -eq 1 ]; then
   echo "Invalid branch $BRANCH"
   exit 1
fi

git checkout $BRANCH
git pull origin $BRANCH

prove -v -w $TEST

sandbox/test-env stop                   
