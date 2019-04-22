JupyterHub on Hadoop
====================

JupyterHub_ provides a secure, multi-user interactive notebook_ environment. It
allows users to access a shared computing environment conveniently through a
webpage, with no local installation required.

JupyterHub is flexible and can be deployed in many different environments. In
the spirit of Zero-to-JupyterHub-Kubernetes_, this guide aims to help you set
up your own JupyterHub on an existing `Hadoop Cluster`_.

Note that this guide is under active development. If you find things unclear or
incorrect, or have any questions/comments, feel free to `create an issue on
github`_.


Overview
--------

JupyterHub is divided into three separate components:

- Multiple **single-user notebook servers** (one per active user)
- An **HTTP proxy** for proxying traffic between users and their respective
  servers.
- A central **Hub** that manages authentication and single-user server
  startup/shutdown.

When deploying JupyterHub on a Hadoop cluster, the **Hub** and **HTTP proxy**
are run on a single node (typically an edge node), and the **single-user
servers** are distributed throughout the cluster.

.. image:: /_images/architecture.svg
    :width: 90 %
    :align: center
    :alt: JupyterHub on Hadoop high-level architecture

The resource requirements for the Hub node are minimal (a minimum of 1 GB RAM
should be sufficient), as user's notebooks (where the actual work is being done)
are distributed throughout the Hadoop cluster reducing the load on any single
node.


Installation
------------

As cluster management practices differ, we hope to provide several options for
installation. Currently only a manual installation tutorial is provided - if
you're interested in providing alternative options (`Cloudera Parcel`_, etc...)
please `get in touch on github`_.

- :doc:`manual-installation`


Customization
-------------

Once basic installation is complete, there are several options for additional
customization.

- :doc:`enable-https`
- :doc:`contents-managers`
- :doc:`jupyterlab`
- :doc:`dask`


.. toctree::
    :hidden:

    installation
    customization


.. _JupyterHub: https://jupyterhub.readthedocs.io/
.. _notebook: https://jupyter.org/
.. _Zero-to-JupyterHub-Kubernetes: https://zero-to-jupyterhub.readthedocs.io/
.. _Hadoop Cluster: https://hadoop.apache.org/
.. _create an issue on github: https://github.com/jcrist/jupyterhub-on-hadoop/issues
.. _Cloudera Parcel: https://github.com/jcrist/jupyterhub-on-hadoop/issues/1
.. _get in touch on github: https://github.com/jcrist/jupyterhub-on-hadoop/
