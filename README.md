# AWS Continuous Integration and Deployment with a Flask App 

## Set Up GitHub Repository

The first step in our CI journey is to set up a GitHub repository to store our Python application's source code. If you already have a repository, feel free to skip this step. Otherwise, let's create a new repository on GitHub by following these steps:

- Go to [github.com](https://github.com) and sign in to your account.
- Create a new repository.
- Give your repository a name and an optional description.
- Choose the appropriate visibility option based on your needs.
- Initialize the repository with a README file.
- Click on the "Create repository" button to create your new GitHub repository.

## Configure AWS CodeBuild

In this step, we'll configure AWS CodeBuild to build our Flask application based on the specifications we define. CodeBuild will take care of building and packaging our application for deployment. Make sure you have saved the parameters needed to log in to Docker Hub in the Systems Manager Parameter Store, with encrypted passwords using KMS.

### Create a buildspec.yml File

Create a `buildspec.yml` file and save it in your repository. 

```yaml
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
      - echo $DOCKER_PASSWORD | docker login --username "$DOCKER_USERNAME" --password-stdin
      - docker build --tag "$DOCKER_URL/$DOCKER_USERNAME/flaskapp:latest" .
      - docker push "$DOCKER_URL/$DOCKER_USERNAME/flaskapp:latest"
artifacts:
  files:
    - '**/*'
```
## Step 2: Creating a Service Role for CodeBuild

- Go to IAM and select the "Role" option from the left sidebar. Click the "Create role" button.
- In the service or use case section, choose "CodeBuild" to allow CodeBuild to call AWS services on your behalf.
- Additionally, add the AWS SSM ACCESS parameter store to the attached role policy.

After creating the service role for the build service, follow these steps:

## Steps for CodeBuild

1. In the AWS Management Console, navigate to the AWS CodeBuild service.
2. Click on the "Create build project" button and provide a name for your build project (e.g., "dolcehar_web_app").
3. Optionally, provide a description of the build project.
4. Restrict the number of concurrent builds based on your budget. For example, limit CodeBuild usage to two developers at a time.
5. Configure the build environment, such as the operating system, runtime, and compute resources required for your Python application.

    ```
    In this example, I chose on-demand infrastructure to optimize cost rather than reserved capacity.

    I selected a managed Ubuntu image from AWS to handle the build process and EC2 compute resources.
    ```

6. Specify the build commands, such as installing dependencies and running tests. Customize this based on your application's requirements.
7. Set up the artifacts configuration to generate the build output required for deployment.
8. Review the build project settings and click on the "Create build project" button to create your AWS CodeBuild project.

## Ensure Docker Daemon Can Run

To ensure your build instance can run the Docker daemon, follow these steps:

***Note: By default, AWS does not install the Docker daemon. You need to enable this setting.***

1. Go to the project, click on "Edit" on the right-hand side of the project.
2. Scroll down to Environment settings.
3. Choose the On-demand option for the provisioning model.
4. Choose Managed Image.
5. Compute should be EC2.
6. The operating system should be Ubuntu, with the standard runtime and the latest standard 7.0 image.
7. Click on Additional settings and scroll down to the "Privileged" setting.
8. Enable the "Privileged" flag if you want to build Docker images or want your builds to get elevated privileges.

Test your build pipeline first to ensure everything is working, then move on to setting up CodePipeline.

## Create an AWS CodePipeline

We are moving forward to CodePipeline setup for Continuous Deployments. AWS CodePipeline will orchestrate the flow of changes from our GitHub repository to the deployment of our application. Let's set it up:

1. Navigate to the AWS CodePipeline service and click on the "Create pipeline" button.
2. Provide a name for your pipeline.
3. Choose an execution method you would like. I selected "superseeded" and click next.
4. For the source stage, select "GitHub" as the source provider.
5. Connect your GitHub account to AWS CodePipeline and select your repository. Choose version 2 and choose your app.
6. Choose the branch you want to use for your pipeline.
7. In the build stage, select "AWS CodeBuild" as the build provider.
8. Choose the build project we created earlier.
9. You can choose to create the deploy stage later.

## Create or Use the Server for Deployment

1. Navigate to the EC2 service on AWS.
2. Click on "Launch instance."
3. Use an Ubuntu image and choose a suitable instance type.
4. Choose a key pair for logins.
5. Allow SSH traffic from your selected IP address or group of whitelisted IP addresses.
6. Make sure to keep the same tags in resources for operation so other team members can easily sort out the services under the same app. Also, mention the environments.

## EC2 Instance CodeDeploy Agent

We need to install an agent or runner on the EC2 instance so that CodeDeploy can deploy the apps inside it.

- Make sure you give this CodeDeploy the right permissions to talk to EC2.

### To install the CodeDeploy agent on Ubuntu Server

Sign in to the instance and enter the following commands, one after the other:

```sh
sudo apt-get update
sudo apt-get install -y ruby
cd /home/ubuntu
wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto



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
## AWS CodeDeploy

1. **Create an Application**
   - Navigate to CodeDeploy and create a new application.
   - Choose a suitable name for your application and select the compute platform.

### Create a Deployment Group

2. **Set Up the Deployment Group**
   - Select "webapp" as the deployment group.
   - Choose a service role that grants CodeDeploy access to necessary AWS services for deployment.
   - For the deployment type, select "in-place" for now.
   - Select the web server EC2 instances and finalize the application configuration based on your load balancing and auto-scaling requirements.

### Create Deployments Using the appspec.yml

3. **Set Up GitHub Integration**
   - Configure the deployment with your GitHub repository, providing the necessary repo and commit details.

## Trigger the CI Process by Adding the Deploy Stage

4. **Add Deploy Stage to CodePipeline**
   - Go to CodePipeline, edit the stages, and add CodeDeploy as an action provider.
   - Select the build artifact.
   - Choose your application and deployment group.

### Triggering the CI Process

In this final step, we'll trigger the CI process by making a change to our GitHub repository. Here's how it works:

1. **Make a Change in GitHub**
   - Go to your GitHub repository and make a change to your Python application's source code. This could be a bug fix, a new feature, or any other modification.
   - Commit and push your changes to the branch configured in your AWS CodePipeline.

2. **Monitor the Pipeline**
   - Head over to the AWS CodePipeline console and navigate to your pipeline.
   - The pipeline should automatically start as soon as it detects changes in your repository.

