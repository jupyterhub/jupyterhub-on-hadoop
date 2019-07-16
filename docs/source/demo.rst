Docker-Compose Demo
-------------------

For demonstration and experimentation purposes, a docker-compose_ setup can be
found `here
<https://github.com/jupyterhub/jupyterhub-on-hadoop/tree/master/docker-demo>`__.

To run, first install docker_ and docker-compose_, following the instructions
for your OS. You'll also need to make sure that docker is started with
sufficient resources - we recommend having at least 4 GB allocated to your
``docker-machine``.

The demo cluster can then be started as follows:

.. code-block:: shell

    # Clone the repository
    $ git clone https://github.com/jupyterhub/jupyterhub-on-hadoop.git

    # Enter the `docker-demo` directory
    $ cd jupyterhub-on-hadoop/docker-demo

    # Start the demo cluster
    $ docker-compose up -d

JupyterHub will then be available on port ``8888`` at your docker-machine
IP address. This IP address can be found at:

.. code-block:: shell

    $ docker-machine inspect --format {{.Driver.IPAddress}})

Once you're done using the demo, it can be shutdown with (from the
``docker-demo`` directory):

.. code-block:: shell

    $ docker-compose down

The demo comes with the following features:

- A realistic Hadoop 3 (`CDH 6`_) cluster (1 master, 1 worker, 1 edge node),
  with Kerberos security enabled.

- 3 user accounts (``alice``, ``bob``, and ``carl``). The password for each is
  ``testpass``.

- Both Jupyter Notebook and JupyterLab are available. The default upon login is
  the Notebook interface, replace ``/tree`` with ``/lab`` in the URL to access
  JupyterLab.

- Each user gets access to a Python 3.7 environment, with common packages like
  ``numpy`` and ``pandas`` already installed.

- Dask_ and Spark_ are both installed and fully configured. See :doc:`dask` and
  :doc:`spark` for more information on use.


For a walkthrough using the same demo cluster, see this video:

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

.. _Docker: https://www.docker.com/
.. _Docker-Compose: https://docs.docker.com/compose/
.. _CDH 6: https://www.cloudera.com/documentation/enterprise/6/6.2/topics/cdh_intro.html
.. _Dask: https://dask.org/
.. _Spark: https://spark.apache.org/
