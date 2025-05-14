pipeline {
    agent any

    environment {
        TF_WORK_DIR = 'terraform'
        LAMBDA_DIR = 'lambda'
        ZIP_NAME = 'lambda_function.zip'
        S3_BUCKET = 'bg-kar-terraform-state'
        S3_KEY = 'lambda-packages/lambda/lambda_function.zip'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Changes & Build Lambda') {
            steps {
                script {
                    def lambdaChanged = sh(script: "git diff --quiet HEAD~1 -- ${LAMBDA_DIR} || echo 'changed'", returnStdout: true).trim()

                    if (lambdaChanged == "changed") {
                        echo "Changes detected in lambda folder. Building package..."

                        sh """
                        chmod +x ${LAMBDA_DIR}/build.sh
                        bash ${LAMBDA_DIR}/build.sh
                        cp ${LAMBDA_DIR}/${ZIP_NAME} ${TF_WORK_DIR}/
                        aws s3 cp ${LAMBDA_DIR}/${ZIP_NAME} s3://${S3_BUCKET}/${S3_KEY}
                        """
                    } else {
                        echo "No changes in lambda folder. Skipping Lambda build and upload."
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_WORK_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_WORK_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_WORK_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
}
