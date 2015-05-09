# A merge of:
### Thomas Wiecki's container. cf. https://github.com/twiecki/pydata_docker_jupyterhub
### and jupyter's demo container. https://github.com/jupyter/docker-demo-images 

FROM debian:jessie
#FROM ubuntu:14.04

MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#minimal install:
RUN apt-get update && apt-get install -y git vim wget build-essential python-dev ca-certificates bzip2 && apt-get clean

#full install:
# Julia dependencies
RUN apt-get install -y julia libnettle4 && apt-get clean

# R dependencies that conda can't provide (X, fonts)
RUN apt-get install -y libxrender1 fonts-dejavu && apt-get clean

# Some more useful installs:
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libfontconfig1


ENV CONDA_DIR /opt/conda

# Install conda for the system:
RUN echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-3.9.1-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --yes conda==3.10.1

ENV HOME /root
ENV SHELL /bin/bash
ENV USER root
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

#minimal install:
RUN conda install --yes ipython-notebook terminado && conda clean -yt

#full install:

# Python packages
RUN conda install --yes numpy pandas scikit-learn matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh pyzmq six theano tornado jinja2 sphinx pygments nose readline sqlalchemy && conda clean -yt

# R packages
RUN conda config --add channels r
RUN conda install --yes r-irkernel r-plyr r-devtools r-rcurl r-dplyr r-ggplot2 r-caret && conda clean -yt

# IJulia and Julia packages
RUN julia -e 'Pkg.add("IJulia")'
RUN julia -e 'Pkg.add("Gadfly")' && julia -e 'Pkg.add("RDatasets")'

# Extra Kernels
RUN pip install --user bash_kernel

# Install PyData modules and IPython dependencies
#RUN conda update --quiet --yes conda && \
#    conda install --quiet --yes numpy scipy pandas matplotlib cython pyzmq scikit-learn seaborn six \
#    	  	  	  	statsmodels theano pip tornado jinja2 sphinx pygments nose readline sqlalchemy

# Set up IPython kernel 
#RUN pip install file:///srv/ipython && \
#    rm -rf /usr/local/share/jupyter/kernels/* && \
#    python2 -m IPython kernelspec install-self

# Clean up
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#RUN conda clean -y -t

#########

#Config files:
RUN ipython profile create
ADD ipython_notebook_config.py /root/.ipython/profile_default/ipython_notebook_config.py 

# Set up shared folder
RUN mkdir /opt/shared_nbs
RUN chmod a+rwx /opt/shared_nbs
# If you have your own custom jupyterhub config, overwrite it.
ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

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

# Convert notebooks to the current format
RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec ipython trust {} \;

WORKDIR /tmp/
# Test python
RUN python -c "import numpy, scipy, pandas, matplotlib, matplotlib.pyplot, sklearn, seaborn, statsmodels, theano"
RUN iptest2
RUN iptest3
# Test ipython

##########NOW INSTALL JUPYTERHUB

# install js dependencies
RUN npm install -g configurable-http-proxy

RUN mkdir -p /srv/

# install jupyterhub
ADD requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

WORKDIR /srv/
ADD . /srv/jupyterhub
WORKDIR /srv/jupyterhub/

RUN pip3 install .
WORKDIR /srv/jupyterhub/

#create filesystem users, inherited by Jupyterhub
ADD users /tmp/users
ADD add_user.sh /tmp/add_user.sh
RUN bash /tmp/add_user.sh /tmp/users
RUN rm /tmp/add_user.sh /tmp/users

# Mark a subdirectory of shared folder into volume for sharing data outside the container
VOLUME /opt/shared_nbs/EXTERNAL

EXPOSE 8888
ONBUILD ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py
CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]

