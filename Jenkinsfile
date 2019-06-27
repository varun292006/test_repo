
pipeline {
    agent any
    
    parameters {
        booleanParam(defaultValue: true, description: '', name: 'userFlag')
    }

    stages {
        stage("source") {
            steps {
                git 'https://github.com/brentlaster/gradle-greetings.git'
            }
        }
        stage("Build") {
            steps {
                echo "This is a build step"
                script{
                def commitChangeset = sh(returnStdout: true, script: 'git diff-tree --no-commit-id --name-status -r HEAD').trim()
                echo commitChangeset
                }
            }
        }
    }
}
