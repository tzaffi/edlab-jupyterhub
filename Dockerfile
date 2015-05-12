########### BEGIN MODDED  twiecki/pydata-docker-jupyterhub
FROM jupyter/jupyterhub

MAINTAINER Zeph Grunschlag <zgrunschlag@gmail.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget libsm6 libxrender1 libfontconfig1
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
#    conda install --quiet --yes numpy scipy pandas matplotlib cython pyzmq scikit-learn seaborn six statsmodels theano pip tornado jinja2 sphinx pygments nose readline sqlalchemy

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
ENV SHELL /bin/bash
ENV CONDA_DIR /opt/conda
RUN echo "CONDA_DIR = $CONDA_DIR"
RUN echo "export PATH=$CONDA_DIR/bin:$PATH" > /etc/profile.d/conda.sh 
RUN grep . /etc/profile.d/conda.sh 

RUN /bin/bash -c "wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh"
#RUN pwd
#RUN ls
#RUN /bin/bash -c "echo $CONDA_DIR"
RUN chmod 777 Miniconda3-3.9.1-Linux-x86_64.sh
RUN  ./Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR
RUN rm Miniconda3-3.9.1-Linux-x86_64.sh 
RUN chmod a+rwx $CONDA_DIR

#RUN $CONDA_DIR/bin/conda install --yes conda==3.10.1
#RUN $CONDA_DR/bin/conda install --yes ipython-notebook terminado && conda clean -yt

ENV HOME /root
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

RUN conda install --yes conda==3.10.1
RUN conda install --yes ipython-notebook terminado && conda clean -yt
RUN ipython profile create

#EXPOSE 8888
#CMD ipython notebook
########### END MODDED jupyter/docker-demo-images/common (aka Docker jupyter/minimal)

########### BEGIN MODDED jupyter/docker-demo-images (aka Docker jupyter/demo)
RUN conda install --yes numpy pandas scikit-learn matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh && conda clean -yt
RUN pip install --user bash_kernel

########### END MODDED jupyter/docker-demo-images (aka Docker jupyter/demo)




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
