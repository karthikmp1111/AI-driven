pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'kar-weather-s3'
        LAMBDA_NAME = 'lambda'
        LAMBDA_PATH = "lambda-functions/lambda"
        PACKAGE_ZIP = "${LAMBDA_PATH}/package.zip"
        TERRAFORM_ZIP = "terraform/lambda_function.zip"
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or destroy Terraform infrastructure')
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/AI-driven.git'
            }
        }

        stage('Verify AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
                        export AWS_DEFAULT_REGION=$AWS_REGION
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Build & Upload Lambda') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    def changes = sh(script: "git diff --quiet origin/main -- ${LAMBDA_PATH}", returnStatus: true)
                    if (changes != 0) {
                        echo "Changes detected for ${LAMBDA_NAME}."

                        sh "bash ${LAMBDA_PATH}/build.sh"
                        sh "aws s3 cp ${PACKAGE_ZIP} s3://${S3_BUCKET}/lambda-packages/${LAMBDA_NAME}/lambda_function.zip"
                        sh "cp ${PACKAGE_ZIP} ${TERRAFORM_ZIP}"
                    } else {
                        echo "No changes in ${LAMBDA_NAME}. Downloading existing zip from S3..."
                        sh "mkdir -p terraform"
                        sh "aws s3 cp s3://${S3_BUCKET}/lambda-packages/${LAMBDA_NAME}/lambda_function.zip ${TERRAFORM_ZIP}"
                    }
                }
            }
        }

        stage('Terraform Init') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
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

    post {
        failure {
            echo 'Build failed. Cleaning up credentials and temporary files.'
        }
        always {
            echo 'Pipeline completed.'
        }
    }
}





// pipeline {
//     agent any

//     environment {
//         AWS_REGION = 'us-west-1'
//         S3_BUCKET = 'kar-weather-s3'
//         LAMBDA_NAME = 'lambda'
//         LAMBDA_PATH = "lambda-functions/lambda"
//         PACKAGE_ZIP = "${LAMBDA_PATH}/package.zip"
//         TERRAFORM_ZIP = "terraform/lambda_function.zip"
//     }

//     parameters {
//         choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or destroy Terraform infrastructure')
//     }

//     options {
//         timestamps()
//         disableConcurrentBuilds()
//     }

//     stages {
//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/karthikmp1111/AI-driven.git'
//             }
//         }

//         stage('Verify AWS Credentials') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
//                     string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
//                 ]) {
//                     sh '''
//                         export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
//                         export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
//                         export AWS_DEFAULT_REGION=$AWS_REGION
//                         aws sts get-caller-identity
//                     '''
//                 }
//             }
//         }

//         stage('Build & Upload Lambda') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'apply' }
//             }
//             steps {
//                 script {
//                     def changes = sh(script: "git diff --quiet origin/main -- ${LAMBDA_PATH}", returnStatus: true)
//                     if (changes != 0) {
//                         echo "Changes detected for ${LAMBDA_NAME}."

//                         // Build Lambda package
//                         sh "bash ${LAMBDA_PATH}/build.sh"

//                         // Upload to S3
//                         sh "aws s3 cp ${PACKAGE_ZIP} s3://${S3_BUCKET}/lambda-packages/${LAMBDA_NAME}/lambda_function.zip"

//                         // Copy to Terraform folder
//                         sh "cp ${PACKAGE_ZIP} ${TERRAFORM_ZIP}"
//                     } else {
//                         echo "No changes in ${LAMBDA_NAME}. Downloading existing zip from S3..."

//                         // Ensure terraform folder exists
//                         sh "mkdir -p terraform"

//                         // Download latest zip from S3 for Terraform to use
//                         sh "aws s3 cp s3://${S3_BUCKET}/lambda-packages/${LAMBDA_NAME}/lambda_function.zip ${TERRAFORM_ZIP}"
//                     }
//                 }
//             }
//         }

//         stage('Terraform Init') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform init'
//                 }
//             }
//         }

//         stage('Terraform Plan') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform plan -out=tfplan'
//                 }
//             }
//         }

//         stage('Terraform Apply') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'apply' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform apply -auto-approve tfplan'
//                 }
//             }
//         }

//         stage('Terraform Destroy') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'destroy' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform destroy -auto-approve'
//                 }
//             }
//         }

//         stage('Clean Workspace') {
//             steps {
//                 cleanWs()
//             }
//         }
//     }

//     post {
//         failure {
//             echo 'Build failed. Cleaning up credentials and temporary files.'
//         }
//         always {
//             echo 'Pipeline completed.'
//         }
//     }
// }
