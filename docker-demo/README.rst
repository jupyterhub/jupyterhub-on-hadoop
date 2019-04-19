JupyterHub on Hadoop Docker Demo
================================

This is a demo setup of JupyterHub on Hadoop deployed via Docker Compose.

Startup
-------

From this directory:

.. code-block:: shell

    $ docker-compose up -d

Usage
-----

Three user accounts have been created:

- ``alice``
- ``bob``
- ``carl``

All have the same password ``testpass``.

After logging in you should be dropped into a Jupyter Notebook with common
Python libraries like Pandas, NumPy, and Dask installed.

Shutdown
--------

From this directory

.. code-block:: shell

    $ docker-compose down
