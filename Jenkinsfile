pipeline {
  agent any

  environment {
    AWS_REGION = 'us-west-1'
    S3_BUCKET = 'bg-kar-terraform-state'
    LAMBDA_PATH = 'lambda'
    ZIP_NAME = 'lambda_function.zip'
  }

  parameters {
    choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or destroy Terraform infrastructure')
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/karthikmp1111/AI-driven.git'
      }
    }

    stage('Setup AWS Credentials') {
      steps {
        withCredentials([
          string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
          string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
        ]) {
          sh '''
          aws configure set aws_access_key_id $AWS_ACCESS_KEY
          aws configure set aws_secret_access_key $AWS_SECRET_KEY
          aws configure set region $AWS_REGION
          '''
        }
      }
    }

    stage('Build and Upload Lambda Package') {
      when {
        expression { params.APPLY_OR_DESTROY == 'apply' }
      }
      steps {
        script {
          if (sh(script: "git diff --quiet HEAD~1 ${LAMBDA_PATH}", returnStatus: true) != 0) {
            echo "Changes detected in Lambda code. Building package..."
            sh "chmod +x ${LAMBDA_PATH}/build.sh && bash ${LAMBDA_PATH}/build.sh"
            sh "cp ${LAMBDA_PATH}/${ZIP_NAME} terraform/"
            sh "aws s3 cp ${LAMBDA_PATH}/${ZIP_NAME} s3://${S3_BUCKET}/lambda-packages/${ZIP_NAME}"
          } else {
            echo "No changes detected in Lambda code. Skipping build and upload."
          }
        }
      }
    }

    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('terraform') {
          sh "test -f ${ZIP_NAME} || echo 'No lambda zip found, assuming unchanged'"
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.APPLY_OR_DESTROY == 'apply' }
      }
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { params.APPLY_OR_DESTROY == 'destroy' }
      }
      steps {
        dir('terraform') {
          sh 'terraform destroy -auto-approve'
        }
      }
    }

    stage('Clean Workspace') {
      steps {
        cleanWs()
      }
    }
  }
}
