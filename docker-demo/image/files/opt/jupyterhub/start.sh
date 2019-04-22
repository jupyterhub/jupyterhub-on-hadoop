#!/usr/bin/env bash

export PATH="/opt/jupyterhub/miniconda/bin:$PATH"
cd /var/jupyterhub
exec jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
