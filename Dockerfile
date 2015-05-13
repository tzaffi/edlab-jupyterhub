########### BEGIN MODDED jupyter/jupyterhub
FROM ipython/ipython
MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

# install jupyterhub compilation dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libxrender1 libfontconfig1

# install js dependencies
RUN npm install -g configurable-http-proxy

RUN mkdir -p /srv/

######################### BEGIN INSTALL CONDA PYTHON:
ENV SHELL /bin/bash
ENV CONDA_DIR /opt/conda
RUN echo "CONDA_DIR = $CONDA_DIR"
RUN echo "export PATH=$CONDA_DIR/bin:$PATH" > /etc/profile.d/conda.sh 
RUN cat /etc/profile.d/conda.sh 

RUN /bin/bash -c "wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh"
RUN pwd
RUN ls
RUN /bin/bash -c "echo $CONDA_DIR"
RUN chmod 777 Miniconda3-3.9.1-Linux-x86_64.sh
RUN ./Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR
RUN rm Miniconda3-3.9.1-Linux-x86_64.sh 
RUN chmod a+rwx $CONDA_DIR

ENV HOME /root
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

RUN conda install --yes conda==3.10.1
RUN conda install --yes ipython-notebook terminado && conda clean -yt
RUN ipython profile create

RUN conda install --yes numpy pandas scikit-learn matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh pyzmq theano sphinx node && conda clean -yt

# TWIECKI runs:
#    conda install --quiet --yes numpy scipy pandas matplotlib cython pyzmq scikit-learn seaborn six statsmodels theano pip tornado jinja2 sphinx pygments nose readline sqlalchemy
# Do we need:  pyzmq? six? theano? pip? tornado? jinja2? sphinx? pygments? node? readline? sqlalchemy?
# We need:  pyzmq theano sphinx node 

RUN pip install --user bash_kernel

######################## END INSTALL CONDA PYTHON
# install jupyterhub
WORKDIR /srv/
RUN git clone --depth 1 https://github.com/jupyter/jupyterhub jupyterhub/
WORKDIR /srv/jupyterhub/
RUN cp requirements.txt /tmp/requirements.txt
RUN /opt/conda/bin/python -m pip install -r /tmp/requirements.txt
RUN /opt/conda/bin/python -m pip install .

# Derivative containers should add jupyterhub config,
# which will be used when starting the application.

EXPOSE 8000

ONBUILD ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py
CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]

########### END MODDED jupyter/jupyterhub

########### BEGIN MODDED  twiecki/pydata-docker-jupyterhub
######## I'VE COMMENTED OUT ALL OF twiecki's Dockerfile 
######## EXCEPT FOR: 
##  1) adding users (as in his README.md)
#FROM jupyter/jupyterhub

#MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

#RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libxrender1 libfontconfig1
#HERE I SHALL RUN MY apt-get etc.

# Here I shall install jupyter/demo
# Install miniconda
#RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
#    bash Miniconda-latest-Linux-x86_64.sh -b -p /opt/miniconda && \
#    rm Miniconda-latest-Linux-x86_64.sh
#ENV PATH /opt/miniconda/bin:$PATH
#RUN chmod -R a+rx /opt/miniconda

# Install PyData modules and IPython dependencies
#RUN conda update --quiet --yes conda && \


# Set up IPython kernel
#RUN pip install file:///srv/ipython && \
#    rm -rf /usr/local/share/jupyter/kernels/* && \
#    python2 -m IPython kernelspec install-self

# Clean up
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#RUN conda clean -y -t

# Test
#RUN python -c "import numpy, scipy, pandas, matplotlib, matplotlib.pyplot, sklearn, seaborn, statsmodels, theano"
########### END MODDED  twiecki/pydata-docker-jupyterhub



########### BEGIN MODDED jupyter/docker-demo-images/common (aka Docker jupyter/minimal)
#ENV DEBIAN_FRONTEND noninteractive

#MOVING THESE TO THE TOP:
#ENV SHELL /bin/bash
#ENV CONDA_DIR /opt/conda
#RUN echo "CONDA_DIR = $CONDA_DIR"
#RUN echo "export PATH=$CONDA_DIR/bin:$PATH" > /etc/profile.d/conda.sh 
#RUN grep . /etc/profile.d/conda.sh 

#RUN /bin/bash -c "wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh"
#RUN pwd
#RUN ls
#RUN /bin/bash -c "echo $CONDA_DIR"
#RUN chmod 777 Miniconda3-3.9.1-Linux-x86_64.sh
#RUN  ./Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR
#RUN rm Miniconda3-3.9.1-Linux-x86_64.sh 
#RUN chmod a+rwx $CONDA_DIR

#RUN $CONDA_DIR/bin/conda install --yes conda==3.10.1
#RUN $CONDA_DR/bin/conda install --yes ipython-notebook terminado && conda clean -yt

#ENV HOME /root
#ENV PATH $CONDA_DIR/bin:$PATH
#WORKDIR $HOME

#RUN conda install --yes conda==3.10.1
#RUN conda install --yes ipython-notebook terminado && conda clean -yt
#RUN ipython profile create

#EXPOSE 8888
#CMD ipython notebook
########### END MODDED jupyter/docker-demo-images/common (aka Docker jupyter/minimal)

########### BEGIN MODDED jupyter/docker-demo-images (aka Docker jupyter/demo)
RUN conda install --yes numpy pandas scikit-learn matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh && conda clean -yt
RUN pip install --user bash_kernel

########### END MODDED jupyter/docker-demo-images (aka Docker jupyter/demo)

####### CONFIGURE iPython Notebooks:
# from this discussion: https://github.com/jupyter/jupyterhub/issues/153
RUN mkdir /etc/ipython
#ADD ipython_notebook_config.py /etc/ipython/ipython_notebook_config.py
#RUN chmod a+rwx /etc/ipython
ADD kernels/ /usr/local/share/jupyter/kernels/

#FROM twiecki/pydata-docker-jupyterhub

# Set up shared folder
RUN mkdir /opt/shared_nbs
RUN chmod a+rwx /opt/shared_nbs

# Create directories for shared notebooks - examples and dashboard
RUN mkdir /opt/shared_nbs/examples
RUN mkdir /opt/shared_nbs/dashboard
RUN chmod a+rwx /opt/shared_nbs/examples
RUN chmod a+rwx /opt/shared_nbs/dashboard

# Download the ipython-in-depth notebooks
WORKDIR /opt/shared_nbs/examples
RUN git clone https://github.com/ipython/ipython-in-depth.git
RUN git clone https://github.com/jvns/pandas-cookbook.git
RUN git clone --depth 1 https://github.com/ipython-books/cookbook-code ipython-cookbook/
ADD notebooks/ /opt/shared_nbs/examples/

# Convert notebooks to the current format and authorize them
#RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
#RUN find . -name '*.ipynb' -exec ipython trust {} \;

ADD users /tmp/users
ADD add_user.sh /tmp/add_user.sh
RUN bash /tmp/add_user.sh /tmp/users
RUN rm /tmp/add_user.sh /tmp/users

# Mark a subdirector of shared folder into volume for sharing data outside the container
VOLUME /opt/shared_nbs/EXTERNAL

