Docker container with a PyData stack and JupyterHub server and sample users
===========================================================================

PyData multi-user IPython/Jupyter notebook server docker container using JupyterHub and conda.


Dockerhub: https://registry.hub.docker.com/u/tzaffi/jupyterhub/)
(Original DockerHub: https://registry.hub.docker.com/u/twiecki/pydata-docker-jupyterhub/)

To set up your own JupyterHub IPython server on top of this using PAM authentication for the Notebook users (the default), use the `add_user.sh` script from the scripts directory. Create a file called `users` with a line for every user that looks like this `<user>,<password>`.

```bash
docker build -t tzaffi/jupyterhub .
# the following could take a L O N G time. Consider setting up automated deploys.
docker push tzaffi/jupyterhub
```



