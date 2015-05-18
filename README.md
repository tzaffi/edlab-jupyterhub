Docker container with a PyData stack and JupyterHub server and sample users
===========================================================================


PyData multi-user IPython/Jupyter notebook server docker container using JupyterHub and conda.

Dockerhub: https://registry.hub.docker.com/u/tzaffi/jupyterhub/

This repository is inspired by the following projects:
* [Jupyter's full demo image](https://github.com/jupyter/docker-demo-images)
* [Jupyter's JupyterHub](https://github.com/jupyter/jupyterhub)
* [Thomas Wiecki's JupyterHub extebsion repo](https://github.com/twiecki/pydata_docker_jupyterhub)

This differs from Wiecki's original repo in that:

* Users (alice, bob and cassandra) are created in the Dockerfile as [users](./users) have been prepopulated and the [add_user.sh](./add_user.sh) script is called
* Note that the file called `users` has a line for every user that looks like this `<user>,<password>`
* Users should change their passwords the first time they log in by opening a terminal window through their jupyter  instance and running the `passwd` command. They will require a rather stringent password with a variety of character types.
* Users can share notebooks by saving into `~/shared_nbs/`
* An external volume is available for mounting via `~/shared_nbs/EXTERNAL`

```bash
# replace tzaffi/edlab-jupyterhub with your own docker repo:
docker build -t tzaffi/edlab-jupyterhub .
# the following could take a L O N G time. Consider setting up automated deploys.
docker push tzaffi/jupyterhub
```

To develop, build and run the docker:

```bash
git clone https://github.com/tzaffi/edlab-jupyterhub.git
cd edlab-jupyterhub
docker build -t tzaffi/edlab-jupyterhub .
sudo docker run -it -p 80:80 -v $(pwd):/opt/shared_nbs tzaffi/edlab-jupyterhub ipython notebook --ip=0.0.0.0 --no-browser
```

To pull and run the docker:

```bash
docker pull tzaffi/edlab-jupyterhub .
sudo docker run -it -p 80:80 -v $(pwd):/opt/shared_nbs tzaffi/edlab-jupyterhub ipython notebook --ip=0.0.0.0 --no-browser
```
