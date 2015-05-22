#FROM ubuntu:14.04
#FROM debian:jessie
FROM ipython/ipython
MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

#############BEGIN FROM ipython/ipython
#MAINTAINER IPython Project <ipython-dev@scipy.org>
#
#ENV DEBIAN_FRONTEND noninteractive
#
## Not essential, but wise to set the lang
## Note: Users with other languages should set this in their derivative image
#RUN apt-get update && apt-get install -y language-pack-en
#ENV LANGUAGE en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8
#
#RUN locale-gen en_US.UTF-8
#RUN dpkg-reconfigure locales
#
## Python binary dependencies, developer tools
#RUN apt-get update && apt-get install -y -q \
#    build-essential \
#    make \
#    gcc \
#    zlib1g-dev \
#    git \
#    python \
#    python-dev \
#    python-pip \
#    python3-dev \
#    python3-pip \
#    python-sphinx \
#    python3-sphinx \
#    libzmq3-dev \
#    sqlite3 \
#    libsqlite3-dev \
#    pandoc \
#    libcurl4-openssl-dev \
#    nodejs \
#    nodejs-legacy \
#    npm
#
## In order to build from source, need less
#RUN npm install -g 'less@<3.0'
#
#RUN pip install invoke
#
#RUN mkdir -p /srv/
#WORKDIR /srv/
##ADD . /srv/ipython
#RUN git clone --depth 1 https://github.com/ipython/ipython ipython/
#WORKDIR /srv/ipython/
#RUN chmod -R +rX /srv/ipython
#
## .[all] only works with -e, so use file://path#egg
## Can't use -e because ipython2 and ipython3 will clobber each other
#RUN pip2 install file:///srv/ipython#egg=ipython[all]
#RUN pip3 install file:///srv/ipython#egg=ipython[all]
#
## install kernels
#RUN python2 -m IPython kernelspec install-self
#RUN python3 -m IPython kernelspec install-self
#
#WORKDIR /tmp/
#
#RUN iptest2
#RUN iptest3
##############END FROM ipython/ipython

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

RUN conda install --yes numpy pandas scikit-learn matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh pyzmq theano sphinx && conda clean -yt

# Test (fails on Debian):
#RUN python -c "import numpy, scipy, pandas, matplotlib, matplotlib.pyplot, sklearn, seaborn, statsmodels, theano"
######################## END INSTALL CONDA PYTHON

######################## BEGIN INSTALL JUPYTERHUB
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

######################## END INSTALL JUPYTERHUB

########### BEGIN INSTALL MORE LANGUAGES
# BIG demo from docker-demo-images/Dockerfile

#NOT SURE IF WE NEED:
RUN apt-get update && apt-get install -y git vim wget build-essential python-dev ca-certificates bzip2 && apt-get clean

###############  JULIA IS CURRENTLY  NOT WORKING. PROBLEM WITH zmq.  TRY AGAIN LATER #############
# Julia dependencies
#RUN apt-get install -y julia libnettle4 && apt-get clean

# R dependencies that conda can't provide (X, fonts)
RUN apt-get install -y libxrender1 fonts-dejavu && apt-get clean

# R packages
RUN conda config --add channels r
RUN conda install --yes r-irkernel r-plyr r-devtools r-rcurl r-dplyr r-ggplot2 r-caret && conda clean -yt

# IJulia and Julia packages
#RUN julia -e 'Pkg.update()'
#RUN julia -e 'Pkg.build("IJulia")'
#RUN julia -e 'Pkg.add("IJulia")'
#RUN julia -e 'Pkg.add("Gadfly")' && julia -e 'Pkg.add("RDatasets")'

# Extra Kernels
RUN pip install --user bash_kernel

########### END INSTALL MORE LANGUAGES

####### CONFIGURE iPython Notebooks:
# from this discussion: https://github.com/jupyter/jupyterhub/issues/153
RUN mkdir /etc/ipython
#ADD ipython_notebook_config.py /etc/ipython/ipython_notebook_config.py
#RUN chmod a+rwx /etc/ipython
ADD kernels/ /usr/local/share/jupyter/kernels/

# Set up shared folder
RUN mkdir /opt/shared_nbs
RUN chmod a+rwx /opt/shared_nbs

# Create directories for shared notebooks - examples and dashboard
RUN mkdir /opt/shared_nbs/examples
RUN mkdir /opt/shared_nbs/dashboard
RUN chmod a+rwx /opt/shared_nbs/examples
RUN chmod a+rwx /opt/shared_nbs/dashboard

# Download the ipython-in-depth notebooks etc.
WORKDIR /opt/shared_nbs/examples
RUN git clone https://github.com/ipython/ipython-in-depth.git
RUN git clone https://github.com/jvns/pandas-cookbook.git
RUN git clone --depth 1 https://github.com/ipython-books/cookbook-code ipython-cookbook/
ADD notebooks/ /opt/shared_nbs/examples/

# Convert notebooks to the current format and authorize them
RUN find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec ipython trust {} \;

ADD users /tmp/users
ADD add_user.sh /tmp/add_user.sh
RUN bash /tmp/add_user.sh /tmp/users
RUN rm /tmp/add_user.sh /tmp/users

# Mark a subdirectory of shared folder into volume for sharing data outside the container
VOLUME /opt/shared_nbs/EXTERNAL
