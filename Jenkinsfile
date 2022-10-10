pipeline {
    agent any
    parameters {
            string(defaultValue: '781950061287', description: '', name: 'AWS_ACCOUNT')
            string(defaultValue: '0.15.0', description: '', name: 'TF_VERSION')
            string(defaultValue: 'test-awss3-bucket-demo', description: '', name: 'BUCKET_NAME')
            string(defaultValue: 'terraform-state-bucket-idp-nonprod', description: '', name: 'ROLE_NAME')


            string(defaultValue: 'true', description: 'To Destroy , change value to false', name: 'CREATE')
    }
    environment {
            BACKEND = 'calibo-test-domain'
            TFSTATE = 's3-bucker/terraform.tfstate'

    }
    stages {
        stage('AWS Get Credentials') {
            steps {
               sh '''
                    set +x
                    export AWS_PROFILE=jenkins
                    aws sts get-caller-identity
                    temp_credentials=$(aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT}:role/jenkins-devops --role-session-name jenkins-deployer | jq -r ".Credentials")
                    echo ${temp_credentials} | jq -r .AccessKeyId > access_key
                    echo ${temp_credentials} | jq -r .SecretAccessKey > secret_key
                    echo ${temp_credentials} | jq -r .SessionToken > secret_token
               '''
            }
        }
        stage('Terraform Validate') {
            steps {
               sh '''
                    set +x
                    rm -rf .terraform* terraform.tfstate*
                    docker run  -v $PWD/demo-18:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${REGION} -e AWS_SESSION_TOKEN=$(cat secret_token) hashicorp/terraform:${TF_VERSION} init
                    docker run  -v $PWD/demo-18:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${REGION} -e AWS_SESSION_TOKEN=$(cat secret_token) hashicorp/terraform:${TF_VERSION} validate
               '''
            }
        }
        stage('Run Terraform') {
            when {
                expression { params.CREATE == 'true' }
            }
            steps {
                   sh '''
                      docker run  -v $PWD/demo-18:/app -w /app -e AWS_ACCESS_KEY_ID=$(cat access_key)  -e AWS_SECRET_ACCESS_KEY=$(cat secret_key) -e AWS_DEFAULT_REGION=${REGION} -e AWS_SESSION_TOKEN=$(cat secret_token) hashicorp/terraform:${TF_VERSION} apply --var bucket_name=${BUCKET_NAME} --var assume_role_name=${ROLE_NAME} -auto-approve
                      '''
            }
        }
    }
    post {
        always {
            cleanWs notFailBuild: true
            sh ''' #! /bin/bash
            pwd
            echo 'Listing out the contents'
            ls -la
            '''
        }
    }
}