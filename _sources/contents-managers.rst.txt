Add a Contents Manager
======================

JupyterHub has a pluggable storage API (called a `contents manager`_) for
persisting notebooks and files. Without a contents manager users will be able
to create notebooks, but their notebooks won't persist between sessions. *Note
that the contents managers are for storing relatively small files (notebooks,
scripts, etc...) and not large files (datasets, etc...).*


Storing Notebooks on HDFS
-------------------------

Notebooks can be persisted to HDFS usint the `jupyter-hdfscm`_ package.

To enable, first install ``jupyter-hdfscm`` in the :ref:`notebook environment
<notebook-environments>` *not* the JupyterHub environment.

.. code-block:: shell

    # Install in the notebook environment
    $ conda install -c conda-forge jupyter-hdfscm

Then add the following to your ``jupyterhub_config.py`` file. This forwards the
contents manager configuration to the notebook process started by
``YarnSpawner``.

.. code-block:: python

    # Enable jupyter-hdfscm
    c.YarnSpawner.args = ['--NotebookApp.contents_manager_class="hdfscm.HDFSContentsManager"']


For more information see the `jupyter-hdfscm documentation`_.


Other Options
-------------

As with authentication, you have several options for Contents Managers. A few
other options:

- s3contents_: stores contents in object stores like S3_ or GCS_
- pgcontents_: stores contents in a Postgres_ database


.. _contents manager: https://jupyter-notebook.readthedocs.io/en/stable/extending/contents.html
.. _jupyter-hdfscm:
.. _jupyter-hdfscm documentation: https://jcrist.github.io/hdfscm/
.. _s3contents: https://github.com/danielfrg/s3contents
.. _S3: https://aws.amazon.com/s3/
.. _GCS: https://cloud.google.com/storage/
.. _pgcontents: https://github.com/quantopian/pgcontents
.. _postgres: https://www.postgresql.org/
