def parts           = env.JOB_NAME.split('/')
def envFolder       = parts[0]
def environmentName = envFolder.replace('terraform-', '')
def repoShort       = parts[1]
def repoFull        = "portfolio-infra-tf-" + repoShort

pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Action')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run terraform test')
    }

    environment {
        ENV         = "${environmentName}"
    }

    options {
        timestamps()
        ansiColor('xterm')
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Context') {
            steps {
                echo "════════════════════════════════════════"
                echo "  Repo    : ${repoFull}"
                echo "  Env     : ${environmentName}"
                echo "  Action  : ${params.ACTION}"
                echo "════════════════════════════════════════"
            }
        }

        stage('Approval') {
            when {
                expression { environmentName == 'prod' && params.ACTION in ['apply', 'destroy'] }
            }
            steps { input(message: "Approve ${params.ACTION} for PROD (${repoFull})?", ok: 'Approve') }
        }

        stage('Checkout') {
            steps {
                sshagent(['github-ssh-key']) {
                    dir("src/${repoFull}") {
                        sh """
                            if [ -d .git ]; then
                                git remote set-url origin git@github.com:${env.GITHUB_ORG}/${repoFull}.git
                                git fetch origin main
                                git reset --hard origin/main
                            else
                                git clone git@github.com:${env.GITHUB_ORG}/${repoFull}.git .
                            fi
                        """
                    }
                }
            }
        }

        stage('Init') {
            steps {
                sshagent(['github-ssh-key']) {
                    dir("src/${repoFull}") {
                        script {
                            if (repoShort == 'bootstrap') {
                                sh 'terraform init -upgrade -backend=false'
                            } else {
                                sh "terraform init -backend-config=backend/${environmentName}.hcl -reconfigure -upgrade"
                            }
                        }
                    }
                }
            }
        }

        stage('Validate') {
            steps {
                dir("src/${repoFull}") {
                    sh 'terraform fmt -recursive'
                    sh 'terraform validate'
                }
            }
        }

        stage('Test') {
            when { expression { params.RUN_TESTS } }
            steps {
                dir("src/${repoFull}") {
                    sh '''
                        if [ -d tests ]; then
                            terraform test
                        else
                            echo "There are no tests in this module"
                        fi
                    '''
                }
            }
        }

        stage('Plan') {
            steps {
                dir("src/${repoFull}") {
                    sh "terraform plan -var-file=envs/${environmentName}.tfvars -out=tfplan"
                }
            }
        }

        stage('Apply / Destroy') {
            when { expression { params.ACTION in ['apply', 'destroy'] } }
            steps {
                dir("src/${repoFull}") {
                    script {
                        if (params.ACTION == 'apply') {
                            sh "terraform apply -auto-approve tfplan"
                        } else {
                            sh "terraform destroy -auto-approve -var-file=envs/${environmentName}.tfvars"
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "${repoFull} — ${params.ACTION} for ${environmentName} OK" }
        failure { echo "${repoFull} — Failed: ${params.ACTION} (${environmentName})" }
        always {
            dir("src/${repoFull}") { sh '[ -f tfplan ] && rm -f tfplan || true' }
        }
    }
}