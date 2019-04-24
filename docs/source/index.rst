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


Walkthrough
-----------

.. raw:: html

    <div style="text-align:center">
      <iframe
        width="640"
        height="385"
        src="https://www.youtube.com/embed/M7T8Xnj9M6c"
        frameborder="0"
        allow="autoplay; encrypted-media;"
        allowfullscreen>
      </iframe>
    </div>


Why JupyterHub?
---------------

JupyterHub is not the only option for providing users a notebook environment
with Hadoop integration, but we believe this setup has some benefits over other
options.

- **Familiar**: JupyterHub provides the same Jupyter_ interface users know and
  love. It integrates well with the existing Data Science ecosystem, and is
  used extensively in both the private and public sector.

- **Extensible**: JupyterHub is open source and community supported, and has a
  large ecosystem of plugins. It can support `dozens of languages`_ (Python, R,
  Julia, Scala...), and user interfaces (Jupyter Notebooks, JupyterLab,
  RStudio...).

- **Scalable**: With JupyterHub, each user gets their own environment running
  in their own private container. This reduces the load on a single node, and
  allows resource usage to scale dynamically with the number of users. For
  large data, tools such as Spark_ and Dask_ work natively with no additional
  overhead.

- **Portable**: JupyterHub is flexible and isn't bound to a single cluster
  manager. It runs great on clusters (Kubernetes, Hadoop, HPC...) as well
  as single machines. This means that if you change your infrastructure in the
  future you can still keep using JupyterHub.


Architecture Overview
---------------------

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
you're interested in providing alternative options (`Cloudera Parcels`_,
RPMs_...) please `get in touch on github`_.

- :doc:`manual-installation`


Customization
-------------

Once basic installation is complete, there are several options for additional
customization.

- :doc:`enable-https`
- :doc:`contents-managers`
- :doc:`jupyterlab`
- :doc:`dask`
- :doc:`spark`


.. toctree::
    :hidden:

    installation
    customization
    demo


.. _JupyterHub: https://jupyterhub.readthedocs.io/
.. _Jupyter:
.. _notebook: https://jupyter.org/
.. _Zero-to-JupyterHub-Kubernetes: https://zero-to-jupyterhub.readthedocs.io/
.. _Hadoop Cluster: https://hadoop.apache.org/
.. _create an issue on github: https://github.com/jcrist/jupyterhub-on-hadoop/issues
.. _dozens of languages: https://github.com/jupyter/jupyter/wiki/Jupyter-kernels
.. _Dask: https://dask.org/
.. _Spark: https://spark.apache.org/
.. _Cloudera Parcels: https://github.com/jcrist/jupyterhub-on-hadoop/issues/1
.. _RPMs: https://github.com/jcrist/jupyterhub-on-hadoop/issues/8
.. _get in touch on github: https://github.com/jcrist/jupyterhub-on-hadoop/
