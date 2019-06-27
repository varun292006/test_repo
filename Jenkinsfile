
pipeline {
    agent any
    
    parameters {
        booleanParam(defaultValue: true, description: '', name: 'userFlag')
        string defaultValue: '/tmp', description: '', name: 'location', trim: true
        string defaultValue: '2.0.0', description: '', name: 'veresion', trim: true
    }

    stages {
        stage("source") {
            steps {
                git 'https://github.com/varun292006/test_repo.git'
            }
        }
        stage("Build") {
            steps {
                echo "This is a build step"
                script{
                def commitChangeset = sh(returnStdout: true, script: 'git diff-tree --no-commit-id --name-status -r HEAD').trim()
                echo commitChangeset
                echo "Value of location is --- ${location}"
                }
            }
        }
    }
    post {
        success {
           mail to: 'varun292006@gmail.com',
                 subject: "Build Successfull: ${currentBuild.fullDisplayName}",
                 body: "Build is successful. More details here - ${env.BUILD_URL}"
        }
        failure {
           mail to: 'varun292006@gmail.com',
                 subject: "Build Failed: ${currentBuild.fullDisplayName}",
                 body: "Something is wrong with ${env.BUILD_URL}"
        }
    }
}
