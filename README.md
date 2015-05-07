Docker container with a PyData stack and JupyterHub server and sample users
===========================================================================

This is a fork of [Thomas Wiecki's JupyterHub repo](https://github.com/twiecki/pydata_docker_jupyterhub).

PyData multi-user IPython/Jupyter notebook server docker container using JupyterHub and conda.

Dockerhub: https://registry.hub.docker.com/u/tzaffi/jupyterhub/

(Wiecki's original DockerHub: https://registry.hub.docker.com/u/twiecki/pydata-docker-jupyterhub/)

This differs from Wiecki's original repo in that:
* Users (alice, bob and cassandra) are created in the Dockerfile as [users](./users) have been prepulated
and the [add_user.sh](./add_user.sh) script is called
* Note that the file called `users` has a line for every user that looks like this `<user>,<password>`
* Users should change their passwords the first time they log in by opening a terminal window through their jupyter 
instance and running the `passwd` command. They will require a rather stringent password with a variety of character types.
* Users can share notebooks by saving into `~/shared_nbs/`

```bash
# replace tzaffi/edlab-jupyterhub with your own docker repo:
docker build -t tzaffi/edlab-jupyterhub .
# the following could take a L O N G time. Consider setting up automated deploys.
docker push tzaffi/jupyterhub
```

To build and run the docker:
```bash
git clone https://github.com/tzaffi/edlab-jupyterhub.git
cd edlab-jupyterhub
docker build -t tzaffi/edlab-jupyterhub .
sudo docker run -it -p 80:80 -v $(pwd):/opt/shared_nbs tzaffi/edlab-jupyterhub ipython notebook --ip=0.0.0.0 --no-browser
```



