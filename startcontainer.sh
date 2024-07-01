set -e
##### Install docker in the ec2 instance ###

sudo apt install docker.io -y

### pulling the docker image
docker pull mr2chowd/flaskapp:latest

## running the docker application at port 5000
docker run -d -p 5000:5000