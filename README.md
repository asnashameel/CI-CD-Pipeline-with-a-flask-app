# AWS Continuous Integration and Deployment with a flask app 

## Set Up GitHub Repository

The first step in our CI journey is to set up a GitHub repository to store our Python application's source code. If you already have a repository, feel free to skip this step. Otherwise, let's create a new repository on GitHub by following these steps:

- Go to github.com and sign in to your account.
- Create a new repository.
- Give your repository a name and an optional description.
- Choose the appropriate visibility option based on your needs.
- Initialize the repository with a README file.
- Click on the "Create repository" button to create your new GitHub repository.

## Configure AWS CodeBuild

In this step, we'll configure AWS CodeBuild to build our flask application based on the specifications we define. CodeBuild will take care of building and packaging our application for deployment. Make sure yoy have saved the parameters needed to login into docker hub are saved in parameter store in Systems Manager with encrypted passwords with KMS.

First step would be create a buildspec.yml file and save it in your repository. 

```
version: 0.2
env:
  parameter-store:
    DOCKER_USERNAME: /docker-credentials/username
    DOCKER_PASSWORD: /docker-credentials/password
    DOCKER_URL: /docker-credentials/url
      
phases:
  install:
    runtime-versions:
      python: 3.11
  pre_build:
    commands:
      - pip install -r requirements.txt
  build:
    commands:
      - echo "Building docker image"
      - echo $DOCKER_PASSWORD |  docker login --username "$DOCKER_USERNAME" --password-stdin
      - docker build --tag "$DOCKER_URL/$DOCKER_USERNAME/flaskapp:latest" .
      - docker push "$DOCKER_URL/$DOCKER_USERNAME/flaskapp:latest"

```

### Second step of creation of Service Role for Code Build

- Go to IAM and choose the "role" option from left side bart and hit "create role" button.
- In the servie or use case , choose "CodeBuild" which allows codebuild to call AWS services on your behalf.
- Also add, parameter store AWS SSM ACCESS to the attached role policy

After the creation of the service role for build service, do the following steps:

### Steps of Code Build

- In the AWS Management Console, navigate to the AWS CodeBuild service.
- Click on the "Create build project" button and provide a name for your build project. In my case, "dolcehar_web_app"
- You can choose to provide a good description of the build project. 
- You can restrict the number of concurrent builds based on the amount of money you have allocated for the project. I will want to restrict to two developers being able to use codebuild to update their codes in the pipeline at once. 

- Configure the build environment, such as the operating system, runtime, and compute resources required for your Python application.

```
In this example, i have chosen on demand infrastructure to optimize cost and not go for reserved capacity. 

Choosing a managed ubuntu image from aws, to handle the build process and EC2 compute process. 

```
- Specify the build commands, such as installing dependencies and running tests. Customize this based on your application's requirements.
- Set up the artifacts configuration to generate the build output required for deployment.
- Review the build project settings and click on the "Create build project" button to create your AWS CodeBuild project.

### Ensure Docker Daemon can be run 

To ensure your build instance you are using have the ability to run docker daemon. Do the following : 

*** Know that by default AWS does not install you the docker daemon, you need to enable this setting ***

- Go to the project, click on Edit on the right hand side of the project. 
- Scroll down to Environment settings 
- Choose On demand option for provisioning model
- Choose Managed Image
- Compute should be EC2 
- Operating system should be Ubuntu for this project, standard runtime and standard 7.0 latest image
- Click on additional setting and scroll down to "Priveleged" setting 
- Enable this "Priveleged" flag if you want to build Docker images or want your builds to get elevated privileges.

Test your build pipeline first to ensure, everything is working then move on to setting up codepipeline.

## Create an AWS CodePipeline
We are moving forward to Codepipeline setup for Continous deployments. AWS CodePipeline will orchestrate the flow of changes from our GitHub repository to the deployment of our application. Let's set it up:

- Navigate to the AWS CodePipeline service and Click on the "Create pipeline" button.
- Provide a name for your pipeline.
- Choose an execution method you would like.I selected "superseeded" and click next.
- For the source stage, select "GitHub" as the source provider.
- Connect your GitHub account to AWS CodePipeline and select your repository. Choose version 2 and choose your app. 
- Choose the branch you want to use for your pipeline.
- In the build stage, select "AWS CodeBuild" as the build provider.
- Choose the build project we created earlier 
- You can choose to create the deploy stage later.

### Create or use the server where you want to deploy your app on

- Navigate to EC2 service on AWS 
- Click on launch a instance 
- Use an ubuntu image and choose a suitable instance type 
- Choose a keypair for logins
- Allow SSH traffic from your selected IP address or group of whitelisted Ip addresses
- Make sure to keep the same tags in resources for operation and other team members can easily sort out the services under same app. Also mention the evironments. 

### EC2 INSTANCE CODE DEPLOY AGENT 

- We need to install an agent or runner in ec2 instance so that code deploy can deploy the apps inside it.

- Make sure you give this Code deploy the right permissions to talk to ec2.

To install the CodeDeploy agent on Ubuntu Server
- Sign in to the instance.

Enter the following commands, one after the other:

```
sudo apt update

sudo apt install ruby-full

sudo apt install wget

cd /home/ubuntu

## /home/ubuntu represents the default user name for an Ubuntu Server instance. If your instance was created using a custom AMI, the AMI owner might have specified a different default user name.

wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install


chmod +x ./install

sudo ./install auto

systemctl status codedeploy-agent

## if system ctl is not running, use the following code ####

systemctl start codedeploy-agent

```



## AWS CODE DEPLOY

- Click on Code Deploy and create an application. 
- Choose a suitable name for your application and compute platform

### Create a deployment group 

- Choose a webapp deployment group
- Choose a service role that has access for Code deploy to access any AWS service for deployment
- Choose in place for now for deploytment type. 
- Click on the webserver ec2 instances and finalize the application based on load balancing and autoscaling stuff you need. 

### Create deployments where you would use the appspec.yml 

- Setup with git hub and provide your repo details and commit details 
## Trigger the CI by adding the Deploy stage Process

- Go to the code pipeline, edit the stages and add code deloy as action provider
- Choose buildartifact
- Choose your application  and deployment group

In this final step, we'll trigger the CI process by making a change to our GitHub repository. Let's see how it works:

- Go to your GitHub repository and make a change to your Python application's source code. It could be a bug fix, a new feature, or any other change you want to introduce.
- Commit and push your changes to the branch configured in your AWS CodePipeline.
- Head over to the AWS CodePipeline console and navigate to your pipeline.
- You should see the pipeline automatically kick off as soon as it detects the changes in your repository.