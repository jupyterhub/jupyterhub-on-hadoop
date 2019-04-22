#!/bin/bash

set -ex

# Make jupyterhub directories
mkdir -p /etc/jupyterhub
mkdir -p /opt/jupyterhub
mkdir -p /var/jupyterhub
mkdir -p /var/log/jupyterhub
chown jupyterhub /var/jupyterhub
chown jupyterhub /var/log/jupyterhub

# Create jupyterhub cookie secret
openssl rand -hex 32 > /etc/jupyterhub/jupyterhub_cookie_secret
chmod 400 /etc/jupyterhub/jupyterhub_cookie_secret
chown jupyterhub /etc/jupyterhub/jupyterhub_cookie_secret

# Install miniconda
curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && /bin/bash /tmp/miniconda.sh -b -p /opt/jupyterhub/miniconda \
    && rm /tmp/miniconda.sh \
    && echo 'export PATH="/opt/jupyterhub/miniconda/bin:$PATH"' >> /root/.bashrc \
    && source /root/.bashrc \
    && conda config --set always_yes yes --set changeps1 no

# Install JupyterHub, dependencies, and user packages. Normally you'd create a
# separate Python environment here (and optionally package it and put it on
# HDFS). However, to save memory usage in the docker images we'll use the same
# environment for everything. Adding dependencies for use by users:
conda install -c conda-forge \
    jupyterhub \
    jupyterhub-yarnspawner \
    jupyter-hdfscm \
    jupyter-server-proxy \
    tornado==5.1.1 \
    notebook \
    ipywidgets \
    pykerberos \
    dask-yarn \
    dask==1.2.0 \
    pyarrow \
    pandas==0.24.2 \
    numpy==1.16.2 \
    nomkl

# Patch out no HTTPS warning in login script to give prettier demos.
sed -i '/^<script>/,/^<\/script>/d' /opt/jupyterhub/miniconda/share/jupyterhub/templates/login.html

# Remove any unused packages
conda clean  -a

# Extra packages that aren't on conda-forge
pip install jupyterhub-kerberosauthenticator --no-deps
pip install jupyterhub-dummyauthenticator --no-deps
