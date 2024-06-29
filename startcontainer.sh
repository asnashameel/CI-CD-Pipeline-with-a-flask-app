set -e

### pulling the docker image
docker pull mr2chowdh/flaskapp

## running the docker application at port 5000
docker run -d -p 5000:5000