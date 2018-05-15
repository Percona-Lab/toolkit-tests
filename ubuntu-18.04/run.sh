#!/bin/bash

set -e 

REPO=${1:-'origin'}
BRANCH=${2:-'3.0'}
TEST=${3:-'t/*'}

echo "Repo: $REPO"
echo "Branch: $BRANCH"
echo "Tests: $TEST"

BASE_DIR='/home/testuser/golang/src/github.com/percona/percona-toolkit/'
cd $BASE_DIR

echo "Deleting all files in /tmp"
rm -rf /tmp/*

export PATH=$PATH:/mysql/bin

echo "Starting the sandbox ..."
sandbox/test-env start
if [ $? -ne 0 ]; then
    echo 'Error: cannot start the sandbox'
    echo 'Plase check the directory containing the MySQL distribution you want to use'
    echo 'is mounted in /tmp/mysql'
    echo 'Example:'
    echo 'docker run --rm -v ${HOME}/mysql/mysql-5.5.56:/tmp/mysql toolkit-test [repo url] [branch] [test file]'
    exit 1
fi

if [ -z "$BRANCH" ]; then
    echo "BRANCH variable is not set"
    exit 1
fi
            
set -e

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
git pull origin 3.0
git checkout -b ${NEW_UUID}
git fetch $REPO $BRANCH

prove -v -w $TEST

sandbox/test-env stop                   
