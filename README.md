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

In this step, we'll configure AWS CodeBuild to build our flask application based on the specifications we define. CodeBuild will take care of building and packaging our application for deployment. 

### Creation of Service Role for Code Build

- Go to IAM and choose the "role" option from left side bart and hit "create role" button.
- In the servie or use case , choose "CodeBuild" which allows codebuild to call AWS services on your behalf.
- Also add, parameter store AWS SSM ACCESS to the attached role policy

After the creationg of the service role for build service, do the following steps:

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

a) Go to the project, click on Edit on the right hand side of the project. 
b) Scroll down to Environment settings 
c) Choose On demand option for provisioning model
d) Choose Managed Image
e) Compute should be EC2 
f) Operating system should be Ubuntu for this project, standard runtime and standard 7.0 latest image
g) Click on additional setting and scroll down to "Priveleged" setting 
h) Enable this "Priveleged" flag if you want to build Docker images or want your builds to get elevated privileges.


## Create an AWS CodePipeline
In this step, we'll create an AWS CodePipeline to automate the continuous integration process for our Python application. AWS CodePipeline will orchestrate the flow of changes from our GitHub repository to the deployment of our application. Let's go ahead and set it up:

- Go to the AWS Management Console and navigate to the AWS CodePipeline service.
- Click on the "Create pipeline" button.
- Provide a name for your pipeline and click on the "Next" button.
- For the source stage, select "GitHub" as the source provider.
- Connect your GitHub account to AWS CodePipeline and select your repository.
- Choose the branch you want to use for your pipeline.
- In the build stage, select "AWS CodeBuild" as the build provider.
- Create a new CodeBuild project by clicking on the "Create project" button.
- Configure the CodeBuild project with the necessary settings for your Python application, such as the build environment,  build commands, and artifacts.
- Save the CodeBuild project and go back to CodePipeline.
- Continue configuring the pipeline stages, such as deploying your application using AWS Elastic Beanstalk or any other suitable deployment option.
- Review the pipeline configuration and click on the "Create pipeline" button to create your AWS CodePipeline.

Awesome job! We now have our pipeline ready to roll. Let's move on to the next step to set up AWS CodeBuild.



## Trigger the CI Process

In this final step, we'll trigger the CI process by making a change to our GitHub repository. Let's see how it works:

- Go to your GitHub repository and make a change to your Python application's source code. It could be a bug fix, a new feature, or any other change you want to introduce.
- Commit and push your changes to the branch configured in your AWS CodePipeline.
- Head over to the AWS CodePipeline console and navigate to your pipeline.
- You should see the pipeline automatically kick off as soon as it detects the changes in your repository.
- Sit back and relax while AWS CodePipeline takes care of the rest. It will fetch the latest code, trigger the build process with AWS CodeBuild, and deploy the application if you configured the deployment stage.