FROM twiecki/pydata-docker-jupyterhub

# Got this from Thomas Wiecki's container. cf. https://github.com/twiecki/pydata_docker_jupyterhub
MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

# Set up shared folder
RUN mkdir /opt/shared_nbs
RUN chmod a+rwx /opt/shared_nbs

# Mark the shared folder as a volume for sharing data outside the container
VOLUME /opt/shared_nbs

# If you have your own custom jupyterhub config, overwrite it.
ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

# Download the ipython-in-depth notebooks
RUN mkdir /opt/shared_nbs/examples
RUN mkdir /opt/shared_nbs/dashboard
RUN chmod a+rwx /opt/shared_nbs/examples
RUN chmod a+rwx /opt/shared_nbs/dashboard
WORKDIR /opt/shared_nbs/examples
RUN git clone https://github.com/ipython/ipython-in-depth.git
#RUN chmod a+rwx /opt/shared_nbs/ipython-in-depth

#back to the main work directory:
WORKDIR /srv/jupyterhub/

ADD users /tmp/users
ADD add_user.sh /tmp/add_user.sh
RUN bash /tmp/add_user.sh /tmp/users
RUN rm /tmp/add_user.sh /tmp/users
