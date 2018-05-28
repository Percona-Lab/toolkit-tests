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
# Do a restart instead of a start to ensure we are deleting any lefover
# from a previous test in the mounted dir (if any)

sandbox/test-env restart
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
git config --global user.name "Percona Docker tests"
git config --global user.email johndoe@example.com

git pull origin 3.0
git checkout -b ${NEW_UUID}

# This is for debugging purposes.
# If the container was started with --entrypoint /bin/bash, running this script with
# --no-test, will start the sandbox and do the pull from the repo.

if [ "$1" = "--no-test" ]; then
    exit 0
fi

git pull $REPO $BRANCH

# -v: verbose, -w: show warnings, -m: join stdout & stderr
prove -vwm $TEST

sandbox/test-env stop                   
