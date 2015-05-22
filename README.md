Docker container with a PyData stack and JupyterHub server and sample users
===========================================================================


PyData multi-user IPython/Jupyter notebook server docker container using JupyterHub and conda.

Dockerhub: https://registry.hub.docker.com/u/tzaffi/jupyterhub/

This repository is inspired by the following projects:
* [Jupyter's full demo image](https://github.com/jupyter/docker-demo-images)
* [Jupyter's JupyterHub](https://github.com/jupyter/jupyterhub)
* [Thomas Wiecki's JupyterHub Docker extender repo](https://github.com/twiecki/pydata_docker_jupyterhub)

This differs from Wiecki's original repo in that:

* Users (alice, bob and cassandra) are created in the container as [users](./users) have 
been prepopulated and the [add_or_remove_user.sh](./add_or_remove_user.sh) script is called
* Users are deleted from the container if their line starts with a dash
* If you inherit from this docker container, 
to delete `alice`, `bob` and `cassandra`, prepend the `users` with
```
-alice
-bob
-cassandra
```
* Note that the file called `users` has a line for every user that looks like this `<user>,<password>`
* Note also that final line should be blank (don't have the EOF on the last user line)
* Users should change their passwords the first time they log in by opening a terminal window through their jupyter  instance and running the `passwd` command. They will require a rather stringent password with a variety of character types.
* Users can share notebooks by saving into `~/shared_nbs/`
* An external volume is available for mounting via `~/shared_nbs/EXTERNAL`

```bash
# replace DOCKER_IMAGE with your own docker image (for me it's tzaffi/edlab-jupyterhub):
docker build -t DOCKER_IMAGE .
# the following could take a L O N G time. Consider setting up automated deploys.
docker push DOCKER_IMAGE
```

To develop, build and run the docker:

```bash
git clone https://github.com/tzaffi/edlab-jupyterhub.git
# MODIFY users approapriately
# Later, each user can change their password from an iPython terminal browser window 
# with the passwd caommand
cd edlab-jupyterhub
docker build -t DOCKER_IMAGE .
sudo docker run -it -p 80:80 -v $(pwd):/opt/shared_nbs DOCKER_IMAGE ipython notebook --ip=0.0.0.0 --no-browser
```

To pull without building and immediately run the docker:

```bash
docker pull tzaffi/edlab-jupyterhub .
sudo docker run -it -p 80:80 -v $(pwd):/opt/shared_nbs tzaffi/edlab-jupyterhub ipython notebook --ip=0.0.0.0 --no-browser
```
