Following: (http://seiler.it/running-docker-amazon-ec2/)

(Replace **nginx-test** by your docker repo)

Build with the command:

sudo docker build -t nginx-test .


Verify build with the command (look for image nginx-test):

sudo docker images


Run with the command:

sudo docker run -p 80:80 -d nginx-test

Run and mount to ~/docker/mounts/mount5 VM path /path/on/vm with the command:

sudo docker run -p 80:80 -v ~/socker/mounts/mount5:/path/on/vm -d nginx-test


See its CONTAINER ID with the command:

sudo docker ps 


Test with the command (should get a response of some sort):

curl localhost


Stop with the command (note the CONTAINER ID you get back from docker ps):

sudo docker stop <CONTAINER ID>


If you get a "no space left on device" message while building try running:

# Dangling images:
docker rmi -f $(docker images -f dangling=true -q)  
# Stopped images:
docker rm $(docker ps -qa)