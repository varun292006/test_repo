node {
    stage('Source'){
        git 'https://github.com/varun292006/test_repo.git'
    }
    stage('Build'){
     echo "This is a build step"
     commitChangeset = sh(returnStdout: true, script: 'git diff-tree --no-commit-id --name-status -r HEAD').trim()
     echo commitChangeset
    }
}
