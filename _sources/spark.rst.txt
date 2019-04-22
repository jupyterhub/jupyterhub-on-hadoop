Integration with Spark
======================

By using JupyterHub, users get secure access to a container running inside the
Hadoop cluster, which means they can interact with Spark *directly* (instead of
by proxy with Livy). This is both simpler and faster, as results don't need to
be serialized through Livy.


Installation
------------

Spark must be installed on your cluster before use. Follow the installation
guidelines from your distribution, or refer to the `Spark-on-Yarn
documentation`_.


Configuration
-------------

PySpark_ isn't installed like a normal Python library, rather it's packaged
separately and needs to be added to the ``PYTHONPATH`` to be importable. This
can be done by configuring ``jupyterhub_config.py`` to find the required
libraries and set ``PYTHONPATH`` in the user's notebook environment. You'll
also want to set ``PYSPARK_PYTHON`` to the same Python path that the notebook
environment is running in.

.. code-block:: python

    import os
    import glob
    # Find pyspark modules to add to PYTHONPATH, so they can be used as regular
    # libraries
    pyspark = '/usr/lib/spark/python/'
    py4j = glob.glob(os.path.join(pyspark, 'lib', 'py4j-*.zip'))[0]
    pythonpath = ':'.join([pyspark, py4j])

    # Set PYTHONPATH and PYSPARK_PYTHON in the user's notebook environment
    c.YarnSpawner.environment = {
        'PYTHONPATH': pythonpath,
        'PYSPARK_PYTHON': '/opt/jupyterhub/miniconda/bin/python',
    }

If you're using an `archived notebook environment <archived-environments>`, you
may instead want to bundle a ``spark`` config directory in the archive, and set
the ``SPARK_CONF_DIR`` to the extracted path. This allows you to specify the
path to the same archive in the config, so your users don't have to themselves.
This might look like:

.. code-block:: text

    # A custom spark-defaults.conf
    # Stored at `<ENV>/etc/spark/spark-defaults.conf`, where `<ENV>` is the top
    # directory of the unarchived Conda/virtual environment.

    # Common configuration
    spark.master yarn
    spark.submit.deployMode client
    spark.yarn.queue myqueue

    # If the spark jars are already on every node, avoid serializing them
    spark.yarn.jars local:/usr/lib/spark/jars/*

    # Path to the archived Python environment
    spark.yarn.dist.archives hdfs:///jupyterhub/example.tar.gz#environment

    # Pyspark configuration
    spark.pyspark.python ./environment/bin/python
    spark.pyspark.driver.python ./environment/bin/python


And the ``jupyterhub_config.py`` file:

.. code-block:: python

    # Add PySpark to PYTHONPATH, same as above
    # ...

    # Set PYTHONPATH and SPARK_CONF_DIR in the user's notebook environment
    c.YarnSpawner.environment = {
        'PYTHONPATH': pythonpath,
        'SPARK_CONF_DIR': './environment/etc/spark'
    }


Usage
-----

Given configuration like above, users may not need to enter any parameters when
creating a ``SparkContext`` - the default values may already be sufficiently
set:

.. code-block:: python

    import pyspark

    # Create a spark context from the defaults set in configuration
    sc = pyspark.SparkContext()

Of course, overrides can always be provided at runtime if needed:

.. code-block:: python

    import pyspark

    conf = pyspark.SparkConf()

    # Override a few default parameters
    conf.set('spark.executor.memory', '512m')
    conf.set('spark.executor.instances', 1)

    # Create a spark context with the overrides
    sc = pyspark.SparkContext(conf=conf)

If all nodes are configured to use the same Python path/archive, then all
dependencies should be available on all workers:

.. code-block:: python

    def some_function(x):
        # Libraries are imported and available from the same environment as the
        # notebook
        import sklearn
        import pandas as pd
        import numpy as np

        # Use the libraries to do work
        return ...


    rdd = sc.parallelize(range(1000)).map(some_function).take(10)


When you're done, the Spark clusters can be shutdown manually, or will be
automatically shutdown when the notebook exits.


Further Reading
---------------

There are additional Jupyter and Spark integrations that may be useful for your
installation. Please refer to their documentation for more information:

- sparkmonitor_: Realtime monitoring of Spark applications from inside the notebook
- jupyter-spark_: Simpler progress indicators for running Spark jobs

Additionally, you may find the following resources useful:

- `Using conda environments with Spark <https://conda.github.io/conda-pack/spark.html>`__
- `Using virtual environments with Spark <https://jcrist.github.io/venv-pack/spark.html>`__


.. _Spark-on-Yarn documentation: https://spark.apache.org/docs/latest/running-on-yarn.html#preparations
.. _sparkmagic: https://github.com/jupyter-incubator/sparkmagic
.. _PySpark: https://spark.apache.org/docs/2.3.1/api/python/index.html
.. _sparkmonitor: https://krishnan-r.github.io/sparkmonitor/
.. _jupyter-spark: https://github.com/mozilla/jupyter-spark
