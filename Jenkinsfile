void setBuildStatus(String message, String context, String state) {
  sh """
    curl \"https://api.github.com/repos/$CONTAINER_IMAGE_PATH/statuses/$GIT_COMMIT\" \
        -H \"Content-Type: application/json\" \
        -H \"Authorization: Bearer $GITHUB_CREDS_PSW\" \
        -X POST \
        -d \"{\\\"description\\\": \\\"$message\\\", \\\"state\\\": \\\"$state\\\", \\\"context\\\": \\\"$context\\\", \\\"target_url\\\": \\\"$BUILD_URL\\\"}\"
  """

}
pipeline {
  environment {
    GITHUB_CREDS = credentials('github-creds')
    CONTAINER_IMAGE_REGISTRY = "ghcr.io"
    CONTAINER_IMAGE_PATH = "itsmethemojo/movie-pile"
    SHORT_COMMIT = "${GIT_COMMIT[0..7]}"
    DEFAULT_BRANCH = "main"
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: rubocop
            image: 192.168.1.101:30006/pipelinecomponents/rubocop:latest
            command:
            - cat
            tty: true
          - name: javascript
            image: 192.168.1.101:30006/library/node:14.14-stretch
            command:
            - cat
            tty: true
          - name: kaniko
            image: ghcr.io/osscontainertools/kaniko:v1.28.4-alpine
            command:
            - cat
            tty: true
          nodeSelector:
            kubernetes.io/arch: amd64
          tolerations:
          - key: "type"
            operator: "Equal"
            value: "amd"
            effect: "NoSchedule"
        '''
    }
  }
  stages {
    stage('lint') {
      steps {
        setBuildStatus("Started", "jenkins-pipeline", "pending");
        container('rubocop') {
          sh 'rubocop src app'
        }
        container('javascript') {
          sh 'npm install --quiet'
          sh 'echo "[INFO] run jscs on views/javascript"'
          sh 'node_modules/jscs/bin/jscs views/javascript'
          sh 'echo "[INFO] run jshint on views/javascript"'
          sh 'node_modules/jshint/bin/jshint views/javascript'
        }
      }
    }

    stage('build') {
      steps {
        container('kaniko') {
          sh 'mkdir -p ~/.docker'
          sh 'if [ \"$GIT_BRANCH\" == \"$DEFAULT_BRANCH\" ]; then echo "" > ~/.docker/push; else echo \"--no-push\" > ~/.docker/push; fi'
          sh 'echo \"{\\"auths\\":{\\"$CONTAINER_IMAGE_REGISTRY\\":{\\"username\\":\\"$GITHUB_CREDS_USR\\",\\"password\\":\\"$GITHUB_CREDS_PSW\\"}}}\" > ~/.docker/config.json'
          sh '/kaniko/executor --dockerfile Dockerfile --context . --build-arg PULLTROUGH_REGISTRY_PREFIX=192.168.1.101:30006/library/ --destination $CONTAINER_IMAGE_REGISTRY/$CONTAINER_IMAGE_PATH:amd64-$SHORT_COMMIT $(cat ~/.docker/push | xargs)'
        }
      }
    }
  }
  post {
    success {
      setBuildStatus("Build Complete", "jenkins-pipeline", "success");
    }
    unstable {
      setBuildStatus("Failed", "jenkins-pipeline", "failure");
    }
    failure {
      setBuildStatus("Failed", "jenkins-pipeline", "failure");
    }
  }
}