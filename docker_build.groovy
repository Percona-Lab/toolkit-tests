//library changelog: false, identifier: 'lib@master', retriever: modernSCM([
//    $class: 'GitSCMSource',
//    remote: 'https://github.com/Percona-Lab/toolkit-tests.git'
//]) _

pipeline {
    environment {
        specName = 'Docker'
    }
    agent {
        label 'docker'
    }
    parameters {
        string(
            defaultValue: 'master',
            description: 'Toolkit tests docker branch',
            name: 'GIT_BRANCH')
        string(
            defaultValue: 'https://github.com/Percona-Lab/toolkit-tests.git',
            description: 'Toolkit tests docker repo',
            name: 'GIT_REPO')
        string(
            defaultValue: 'ubuntu-14.04 ubuntu-16.04 ubuntu-18.04',
            description: 'Distributions to rebuild (must be the same as directories inside repo)',
            name: 'REQ_DISTRO')
    }
    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
    }

    stages {
        stage('Prepare') {
            steps {
                sh '''
                  for distro in ${REQ_DISTRO}; do
                      sudo docker rmi perconalab/toolkit-tests:toolkit-test-${distro} --force || true
                  done
                  rm -rf ${GIT_REPO}
                  git clone ${GIT_REPO} --branch ${GIT_BRANCH} --depth 1
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                  pushd toolkit-tests
                  for distro in ${REQ_DISTRO}; do
                      pushd ${distro}
                      sudo docker build --tag=perconalab/toolkit-tests:toolkit-test-${distro} .
                      popd
                  done
                  popd
                '''
            }
        }

        stage('Upload') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'hub.docker.com', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh """
                        sudo docker login -u "${USER}" -p "${PASS}"
                    """
                }
                sh '''
                    for distro in ${REQ_DISTRO}; do
                        sudo docker push perconalab/toolkit-tests:toolkit-test-${distro}
                    done
                '''
                //sh """
                //    sudo docker rm -f \$(sudo docker ps -aq) || true
                //    sudo docker rmi -f \$(sudo docker images -q) || true
                //"""
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}
