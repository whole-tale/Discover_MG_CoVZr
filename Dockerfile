FROM jupyter/all-spark-notebook:e7000ca1416d

# Install JDK
USER root
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk scala && apt-get clean

# Import the data
USER $NB_USER
ADD --chown=jovyan:users figures /home/$NB_USER/work/figures
ADD --chown=jovyan:users machine-learning /home/$NB_USER/work/machine-learning
ADD --chown=jovyan:users scripts /home/$NB_USER/work/figures/scripts
ADD --chown=jovyan:users README.md /home/$NB_USER/work/README.md
ADD --chown=jovyan:users requirements.txt /home/$NB_USER/work/requirements.txt
ADD --chown=jovyan:users Sample_key.pdf /home/$NB_USER/work/Sample_key.pdf

# Build the software
WORKDIR /home/$NB_USER/work/machine-learning
RUN chmod +x install.sh && ./install.sh && \
    find magpie -name "build" -type d | xargs rm -r

# Change the default mpl backend
RUN mkdir -p ~/.config/matplotlib && echo "backend : Agg" > ~/.config/matplotlib/matplotlibrc

# Fix the permissions
RUN fix-permissions /home/$NB_USER 

RUN jupyter notebook --generate-config   # takes care of permissions

COPY ./.wt/jupyter_notebook_config.py /home/$NB_USER/.jupyter/jupyter_notebook_config.py
COPY ./.wt/custom.js /home/$NB_USER/.jupyter/custom/custom.js
