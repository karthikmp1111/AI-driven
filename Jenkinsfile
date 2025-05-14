pipeline {
  agent any

  environment {
    AWS_REGION = "us-west-1"
    S3_BUCKET = "bg-kar-terraform-state"
    LAMBDA_PATH = "lambda" // directory containing lambda_function.py and build.sh
    LAMBDA_S3_KEY = "lambda-packages/lambda/lambda_function.zip"
  }

  parameters {
    choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or Destroy Terraform infra')
  }

  stages {
    stage('Build Lambda Package') {
      steps {
        dir("${env.LAMBDA_PATH}") {
          echo "Building Lambda zip..."
          sh "bash build.sh"
        }
      }
    }

    stage('Upload to S3') {
      steps {
        echo "Uploading Lambda zip to S3..."
        sh "aws s3 cp ${LAMBDA_PATH}/lambda_function.zip s3://${S3_BUCKET}/${LAMBDA_S3_KEY}"
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
          script {
            if (params.APPLY_OR_DESTROY == 'apply') {
              sh 'terraform plan -out=tfplan'
            } else {
              sh 'terraform destroy -auto-approve'
            }
          }
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
  }
}
