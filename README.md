Docker container with a PyData stack and JupyterHub server and sample users
===========================================================================

This is a fork of [Thomas Wiecki's JupyterHub repo](https://github.com/twiecki/pydata_docker_jupyterhub).

PyData multi-user IPython/Jupyter notebook server docker container using JupyterHub and conda.

Dockerhub: https://registry.hub.docker.com/u/tzaffi/jupyterhub/)

(Original DockerHub: https://registry.hub.docker.com/u/twiecki/pydata-docker-jupyterhub/)

To set up your own JupyterHub IPython server on top of this using PAM authentication for the Notebook users (the default), use the `add_user.sh` script from the scripts directory. Create a file called `users` with a line for every user that looks like this `<user>,<password>`.

```bash
# replace tzaffi/edlab-jupyterhu with your own docker repo:
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



