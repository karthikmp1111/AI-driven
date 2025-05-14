pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'bg-kar-terraform-state'
        LAMBDA_FOLDER = 'lambda'
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose apply or destroy')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/AI-driven.git'
            }
        }

        stage('Configure AWS CLI') {
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
                    def hasChanges = sh(script: "git diff --quiet HEAD~1 ${LAMBDA_FOLDER}", returnStatus: true) != 0
                    if (hasChanges) {
                        echo "Changes detected in lambda folder. Building package..."
                        sh "bash ${LAMBDA_FOLDER}/build.sh"
                        sh "aws s3 cp ${LAMBDA_FOLDER}/lambda_function.zip s3://$S3_BUCKET/lambda-packages/lambda/lambda_function.zip"
                    } else {
                        echo "No changes in lambda folder. Skipping build."
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
