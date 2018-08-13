library changelog: false, identifier: 'lib@master', retriever: modernSCM([
    $class: 'GitSCMSource',
    remote: 'https://github.com/Percona-Lab/toolkit-tests.git'
]) _

pipeline {
    environment {
        specName = 'Docker'
    }
    agent {
        label 'docker-01'
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
        stage('Cleanup') {
            steps {
                sh '''
                  for distro in ${REQ_DISTRO}; do
                      docker rmi perconalab/toolkit-tests:toolkit-test-${distro} --force || true
                  done
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                  for distro in ${REQ_DISTRO}; do
                      pushd ${distro}
                      docker build --tag=perconalab/toolkit-tests:toolkit-test-${distro} .
                      popd
                  done
                '''
            }
        }

        stage('Upload') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'hub.docker.com', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh """
                        for distro in ${REQ_DISTRO}; do
                            sudo docker login -u "${USER}" -p "${PASS}"
                            sudo docker push perconalab/toolkit-tests:toolkit-test-${distro}
                        done
                    """
                }
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
        success {
            slackSend channel: '@tomislav', color: '#00FF00', message: "[${specName}]: build finished"
        }
        failure {
            slackSend channel: '@tomislav', color: '#FF0000', message: "[${specName}]: build failed"
        }
    }
}
