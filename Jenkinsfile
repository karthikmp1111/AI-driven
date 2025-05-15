pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'kar-weather-s3'
        LAMBDA_DIR = 'lambda-functions' // 🔄 Use actual folder name
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
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

        stage('Build and Upload Lambda Packages') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                script {
                    // 🔄 Discover all subfolders (lambda1, lambda2, ...)
                    def lambdaDirs = sh(script: "find ${LAMBDA_DIR} -mindepth 1 -maxdepth 1 -type d -exec basename {} \\;", returnStdout: true).trim().split("\n")

                    lambdaDirs.each { lambdaName ->
                        def lambdaPath = "${LAMBDA_DIR}/${lambdaName}"

                        if (!fileExists("${lambdaPath}/build.sh")) {
                            echo "Skipping ${lambdaName} — no build.sh found"
                            return
                        }

                        // ✅ More resilient change detection
                        def hasChanges = sh(script: "git diff --quiet HEAD~1 -- ${lambdaPath} || git log -1 --oneline -- ${lambdaPath}", returnStatus: true) != 0

                        if (hasChanges) {
                            echo "Changes detected in ${lambdaName}, building..."

                            sh "chmod +x ${lambdaPath}/build.sh"
                            sh "bash ${lambdaPath}/build.sh"

                            sh "aws s3 cp ${lambdaPath}/package.zip s3://${S3_BUCKET}/lambda-packages/${lambdaName}/package.zip"
                        } else {
                            echo "No changes in ${lambdaName}, skipping build."
                        }
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




// pipeline {
//   agent any

//   environment {
//     AWS_REGION = 'us-west-1'
//     S3_BUCKET = 'kar-weather-s3'
//     LAMBDA_NAME = 'lambda'
//     ZIP_NAME = 'lambda_function.zip'
//     S3_LAMBDA_KEY = "lambda-packages/${LAMBDA_NAME}/${ZIP_NAME}"
//   }

//   parameters {
//     choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Apply or destroy Terraform infrastructure')
//   }

//   stages {
//     stage('Checkout Code') {
//       steps {
//         git branch: 'main', url: 'https://github.com/karthikmp1111/AI-driven.git'
//       }
//     }

//     stage('Setup AWS Credentials') {
//       steps {
//         withCredentials([
//           string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
//           string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
//         ]) {
//           sh '''
//             aws configure set aws_access_key_id $AWS_ACCESS_KEY
//             aws configure set aws_secret_access_key $AWS_SECRET_KEY
//             aws configure set region $AWS_REGION
//           '''
//         }
//       }
//     }

//     stage('Build and Upload Lambda Package') {
//       when {
//         expression { params.APPLY_OR_DESTROY == 'apply' }
//       }
//       steps {
//         script {
//           def hasChanges = sh(script: "git diff --quiet HEAD~1 ${LAMBDA_NAME}", returnStatus: true) != 0
//           def zipExists = fileExists("${LAMBDA_NAME}/${ZIP_NAME}")

//           if (hasChanges || !zipExists) {
//             echo "Changes detected or zip missing — building and uploading Lambda package."
//             sh """
//               cd ${LAMBDA_NAME}
//               chmod +x build.sh
//               ./build.sh
//               aws s3 cp ${ZIP_NAME} s3://${S3_BUCKET}/${S3_LAMBDA_KEY}
//             """
//           } else {
//             echo "No changes to Lambda and zip already exists — skipping build/upload."
//           }
//         }
//       }
//     }

//     stage('Copy or Download Lambda Zip') {
//       steps {
//         script {
//           if (fileExists("${LAMBDA_NAME}/${ZIP_NAME}")) {
//             echo "Copying built zip to terraform directory"
//             sh "cp ${LAMBDA_NAME}/${ZIP_NAME} terraform/${ZIP_NAME}"
//           } else {
//             echo "Zip not found locally. Downloading from S3"
//             sh "aws s3 cp s3://${S3_BUCKET}/${S3_LAMBDA_KEY} terraform/${ZIP_NAME}"
//           }
//         }
//       }
//     }

//     stage('Terraform Init') {
//       steps {
//         dir('terraform') {
//           sh 'terraform init -reconfigure'
//         }
//       }
//     }

//     stage('Terraform Plan') {
//       steps {
//         dir('terraform') {
//           sh 'terraform plan -out=tfplan'
//         }
//       }
//     }

//     stage('Terraform Apply') {
//       when {
//         expression { params.APPLY_OR_DESTROY == 'apply' }
//       }
//       steps {
//         dir('terraform') {
//           sh 'terraform apply -auto-approve tfplan'
//         }
//       }
//     }

//     stage('Terraform Destroy') {
//       when {
//         expression { params.APPLY_OR_DESTROY == 'destroy' }
//       }
//       steps {
//         dir('terraform') {
//           sh 'terraform destroy -auto-approve'
//         }
//       }
//     }

//     stage('Clean Workspace') {
//       steps {
//         cleanWs()
//       }
//     }
//   }
// }
