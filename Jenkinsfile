pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_db_password = credentials('db_password')  
    }

    stages {

        stage('Install Terraform with Ansible') {
            steps {

                // Run the Ansible playbook to install Terraform if it's not installed
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key-id', keyFileVariable: 'SSH_KEY')]) {

                    ansiblePlaybook inventory: 'Ansible/inventory.ini',
                                    playbook: 'Ansible/playbooks/install_terraform.yml',
                                    extras: "--private-key=${env.SSH_KEY}"
                }  
            }
        }

        stage('Configuration Formatting') {
            steps {
                echo 'Running Terraform formatting check...'
                dir('infra') {
                    sh 'terraform fmt -recursive'
                    sh 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Initilize Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-keys-cred']]) {
                    dir('infra') {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('Configuration Validation') {
            steps {
                echo 'Validating Terraform configuration...'
                dir('infra') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                echo 'Planning Terraform changes...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-keys-cred']]) {
                    dir('infra') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Provision Resources') {
            steps {
                input message: 'Do you want to provision the resources?'
                echo 'Applying Terraform changes...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-keys-cred']]) {
                    dir('infra') {
                        sh 'terraform apply -auto-approve tfplan'
                        sh 'terraform output -json > ../Ansible/terraform_outputs.json'
                    }
                }
                
            }
        }

        stage('Configure Virtual Machines with Ansible') {
            steps {

                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key-id', keyFileVariable: 'SSH_KEY')]) {
                    script {
                        echo 'Running Ansible playbooks for software installation...'

                        // List of playbooks to run
                        def playbooks = ['Ansible/playbooks/install_docker_dockercompose.yml', 'Ansible/playbooks/config_jenk_dock_access.yml', 'Ansible/playbooks/fix_jenkins_sudoer.yml','Ansible/playbooks/install_semver.yml']

                        for (playbook in playbooks) {
                            ansiblePlaybook inventory: 'Ansible/inventory.ini',
                                            playbook: playbook,
                                            extras: "--private-key=${env.SSH_KEY}",
                                            extraVars: [
                                                'db_host': sh(script: "jq -r .rds_endpoint.value Ansible/terraform_outputs.json", returnStdout: true).trim()
                                            ]
                        }
                    }
                }

            }
        }

        stage('Destroy Resources') {
            steps {
                script {
                    def destroyResources = input(
                        message: 'Do you want to destroy the resources?',
                        parameters: [choice(name: 'Proceed with Destroy', choices: ['Yes', 'No'], description: 'Select "Yes" to destroy resources, "No" to skip')]
                    )

                    if (destroyResources == 'Yes') {
                        echo 'Destroying Terraform-managed infrastructure...'
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-keys-cred']]) {
                            dir('infra') {
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    } else {
                        echo 'Skipping resource destruction as per user choice.'
                    }
                }                
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        } 
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
