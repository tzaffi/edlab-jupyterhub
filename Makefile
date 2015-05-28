dd: images server

images: edlab dd

edlab:
	docker build -t edlab/jupyterhub .
dd:
	-docker build -t edlab/dd .
	-chmod 777 /root/ddmount/EXTERNAL

server:
	docker run -p 80:8000 -v /root/ddmount/EXTERNAL:/opt/shared_nbs/EXTERNAL -d edlab/dd

nuke:
	-docker stop `docker ps -aq`
	-docker rm -fv `docker ps -aq`
	-docker images -q --filter "dangling=true" | xargs docker rmi

.PHONY: nuke