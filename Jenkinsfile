try{
    node{
        def mavenHome
        def mavenCMD
        def docker
        def dockerCMD
        def tagName = "1.0"
        def jobstatus
        
        stage('Preparation'){
            echo "Preparing the Jenkins environment with required tools..."
            mavenHome = tool name: 'maven-3', type: 'maven'
            mavenCMD = "${mavenHome}/bin/mvn"
            docker = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
            dockerCMD = "$docker/bin/docker"
        }
        
        stage('git checkout'){
            echo "Checking out the code from git repository..."
            git branch: "${env.branch}", url: "${env.gitUrl}"
        }
            

        
        stage('Build, Test and Package'){
            echo "Building the bootcamp application..."
            sh "${mavenCMD} clean package"
        }
        
        stage('Sonar Scan'){
            echo "Scanning application for vulnerabilities..."
            sh "${mavenCMD} sonar:sonar -Dsonar.projectKey=${env.sonarProjectKey} -Dsonar.host.url=${env.sonarUrl} -Dsonar.login=${env.sonarLoginId}"
        }
        
        
                
        stage('App scan'){
            
            // Makes buid unstable when the code is vulnerable as per scan report
            // try{
            //   snykSecurity snykInstallation: 'snyk-install', snykTokenId: 'api'
            // }catch(error){
            //     unstable('App Scan failed!')
            // }
            
             snykSecurity failOnIssues: false, snykInstallation: 'snyk-install', snykTokenId: 'api'
        }
            
        
        stage('Junit tests'){
            echo "Executing Regression Test Suits..."
            // command to execute selenium test suits
            sh "${mavenCMD} test site"
        }
        
        stage('Publish Rreport'){
            echo "Publishing HTML report.."
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
        }
        
        stage('Build Docker Image'){
            echo "Building docker image for bootcamp application ..."
            sh "${dockerCMD} build -t mrasto/batch-10:${tagName} ."
        }
        
        stage("Push Docker Image to Docker Registry"){
            echo "Pushing image to docker hub"
            withCredentials([string(credentialsId: 'pass', variable: 'dockerHubPwd')]) {
                sh "${dockerCMD} login -u mrasto -p ${dockerHubPwd}"
                sh "${dockerCMD} push mrasto/batch-10:${tagName}"

            }        
            
        }
        
        stage('Deploy Application'){
            echo "Installing desired software.."
            echo "Bring docker service up and running"
            echo "Deploying application"
            ansiblePlaybook credentialsId: 'ubuntu-ssh', disableHostKeyChecking: true, installation: 'ansible 2.11.1', inventory: '/etc/ansible/hosts', playbook: "${env.playbook}"
        }
        
        stage('Clean up'){
            echo "Cleaning up the workspace..."
            cleanWs()
            currentBuild.result = "SUCCESS"
        }
    }
    
    }
catch(Exception e){
    
    echo "Exception occured..."
    currentBuild.result="FAILURE"
    emailext attachLog: true, attachmentsPattern: "${env.JOB_NAME}#${env.BUILD_NUMBER}-${currentBuild.result}.log", body: "Your ${jobstatus}", subject: "Build Result - ${env.JOB_NAME}#${env.BUILD_NUMBER} - ${currentBuild.result}", to:  "${devmail}"

    throw e // rethrow the error so that it gets printed in the job log, and so the job fails
    //send an failure email notification to the user.
}
finally {
    
    (currentBuild.result!= "ABORTED") && node("master") {
        echo "finally gets executed and end an email notification for every build"
        
        if(currentBuild.result == "FAILURE"){
            jobstatus = 'Build Job has been failed!'
        }
        
        if(currentBuild.result == "SUCCESS"){
           jobstatus = 'Build Job has been successful!'
        }
        
        emailext attachLog: true, attachmentsPattern: "${env.JOB_NAME}#${env.BUILD_NUMBER}-${currentBuild.result}.log", body: "Your ${jobstatus}", subject: "Build Result - ${env.JOB_NAME}#${env.BUILD_NUMBER} - ${currentBuild.result}", to: "${devmail}"
    }

}
