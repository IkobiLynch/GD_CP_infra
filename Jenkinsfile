pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_db_password = credentials('db_password')  
    }

    stages {
        
        stage('Configuration Formatting') {
            steps {
                echo 'Running Terraform formatting check...'
                dir('infra') {
                    sh 'terraform fmt -check -recursive'
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
                dir('infra') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Provision Resources') {
            steps {
                input message: 'Do you want to provision the resources?'
                echo 'Applying Terraform changes...'
                dir('infra') {
                    sh 'terraform apply -auto-approve tfplan'
                    sh 'terraform output -json > ../Ansible/terraform_outputs.json'
                }
            }
        }

        stage('Configure Virtual Machines with Ansible') {
            steps {
                script {
                    echo 'Running Ansible playbooks for software installation...'

                    // List of playbooks to run
                    def playbooks = ['Ansible/playbooks/point_app_to_rds.yml', 'Ansible/playbooks/install_docker_dockercompose.yml']

                    for (playbook in playbooks) {
                        ansiblePlaybook credentialsId: 'ssh-key-id',
                                        inventory: 'Ansible/inventory.ini',
                                        playbook: playbook,
                                        extraVars: [
                                            'db_host': sh(script: "jq -r .rds_endpoint.value Ansible/terraform_outputs.json", returnStdout: true).trim()
                                        ]
                    }
                }
            }
        }

        stage('Destroy Resources') {
            steps {
                input message: 'Do you want to destroy the resources?'
                echo 'Destroying Terraform-managed infrastructure...'
                dir('infra') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
