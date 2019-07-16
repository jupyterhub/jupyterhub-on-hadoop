Configure YarnSpawner
=====================

We now have JupyterHub installed, but it can't really do anything yet. For
JupyterHub to manage user's notebook servers, we need to configure a Spawner_
for it to use. YarnSpawner_ is a Spawner implementation that launches
notebook servers on Apache Hadoop/YARN clusters. Here we'll discuss
installation and configuration of this spawner, for more information see
the `YarnSpawner documentation`_

.. contents:: :local:
    

Install jupyterhub-yarnspawner
------------------------------

Yarnpawner should be installed in the same environment that JupyterHub is
running in.

.. code-block:: bash

    $ conda install -c conda-forge jupyterhub-yarnspawner -y


Set the JupyterHub Spawner Class
--------------------------------

Tell JupyterHub to use ``YarnSpawner`` by adding the following line to your
``jupyterhub_config.py``:

.. code-block:: python

    c.JupyterHub.spawner_class = 'yarnspawner.YarnSpawner'


Configure the Hub Connect IP
----------------------------

By default JupyterHub runs its internal communications server on ``127.0.0.1``,
meaning its only accesible from the machine running JupyterHub.

Since the servers started by ``YarnSpawner`` are running on other machines in
the cluster, we'll need to update this address to something more accessible:

.. code-block:: python

    # Set to '' for all interfaces. Can also set to the hostname of the
    # JupyterHub machine.
    c.JupyterHub.hub_ip = ''


Enable Proxy User Permissions
-----------------------------

YarnSpawner makes full use of Hadoop's security model, and will start Jupyter
notebook server's in containers with the requesting user's permissions (e.g. if
``alice`` logs in to JupyterHub, their notebook server will be running as user
``alice``). To accomplish this, JupyterHub needs `proxy user`_ permissions.
This allows the JupyterHub server to perform actions impersonating another user.

For JupyterHub to work properly, you'll need to enable `proxy user`_
permissions for the ``jupyterhub`` user account. The users ``jupyterhub`` has
permission to impersonate can be restricted to certain groups, and requests to
impersonate may be restricted to certain hosts. At a minimum, ``jupyterhub``
will require permission to impersonate any JupyterHub user, with requests
allowed from at least the host running JupyterHub.

.. code-block:: xml

    <property>
      <name>hadoop.proxyuser.jupyterhub.hosts</name>
      <value>host-where-jupyterhub-is-running</value>
    </property>
    <property>
      <name>hadoop.proxyuser.jupyterhub.groups</name>
      <value>group1,group2</value>
    </property>

If looser restrictions are acceptable, you may also use the wildcard ``*``
to allow impersonation of any user or from any host.

.. code-block:: xml

    <property>
      <name>hadoop.proxyuser.jupyterhub.hosts</name>
      <value>*</value>
    </property>
    <property>
      <name>hadoop.proxyuser.jupyterhub.groups</name>
      <value>*</value>
    </property>

See the `proxy user`_ documentation for more information.


.. _create-spawner-keytab:

Enable Kerberos Security (Optional)
-----------------------------------

If your cluster has Kerberos enabled, you'll also need to create a principal
and keytab for the ``jupyterhub`` user.

.. code-block:: shell

    # Create the jupyterhub principal
    $ kadmin -q "addprinc -randkey jupyterhub@YOUR_REALM.COM"

    # Create a keytab
    $ kadmin -q "xst -norandkey -k /etc/jupyterhub/jupyterhub.keytab

Store the keytab file wherever you see fit (we recommend storing it along with
the JupyterHub configuration, as above). You'll also want to make sure that
``jupyterhub.keytab`` is only readable by the ``jupyterhub`` user.

.. code-block:: shell

    $ chown jupyterhub /etc/jupyterhub/jupyterhub.keytab
    $ chmod 400 /etc/jupyterhub/jupyterhub.keytab

To configure JupyterHub to use this keytab file, you'll need to add the
following line to your ``jupyterhub_config.py``:

.. code-block:: python

    # The principal JupyterHub is running as
    c.YarnSpawner.principal = 'jupyterhub'

    # Path to the keytab you created
    c.YarnSpawner.keytab = '/etc/jupyterhub/jupyterhub.keytab'


.. _notebook-environments:

Specifying Python Environments
------------------------------

Since the user's notebook servers will be each running in their own YARN
container, you'll need to provide a way for Python environments to be available
to these containers. You have a few options here:

- Install identical Python environments on every node
- Archive environments to be distributed to the container at runtime (recommended)

In either case, the Python environment requires at minimum:

- ``jupyterhub-yarnspawner``
- ``jupyterhub``
- ``notebook``


Using a Local Environment
^^^^^^^^^^^^^^^^^^^^^^^^^

If you've installed identical Python environments on every node, you only need
to configure ``YarnSpawner`` to use the provided Python. This could be done a
few different ways:


.. code-block:: python

    # Use the path to python in the startup command
    c.YarnSpawner.cmd = '/path/to/python -m yarnspawner.singleuser'

    # OR
    # Activate a local conda environment before startup
    c.YarnSpawner.prologue = 'conda activate /path/to/your/environment'

    # OR
    # Activate a virtual environment before startup
    c.YarnSpawner.prologue = 'source /path/to/your/environment/bin/activate'


.. _archived-environments:

Using an Archived Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

YARN also provides mechanisms to "localize" files/archives to a container
before starting the application. This can be used to distribute Python
environments at runtime. This approach is appealing in that it doesn't require
installing anything throughout the cluster, and allows for centrally managing
your user's Python environments.

Packaging environments for distribution is usually accomplished using

- conda-pack_ for conda_ environments
- venv-pack_  for virtual environments (both venv_ and virtualenv_ supported)

Both are tools for taking an environment and creating an archive of it in a way
that (most) absolute paths in any libraries or scripts are altered to be
relocatable. This archive then can be distributed with your application, and
will be automatically extracted during `YARN resource localization`_

Below we demonstrate creating and packaging a Conda environment containing all
the required Jupyter packages, as well as ``pandas`` and ``scikit-learn``.
Additional packages could be added as needed.


**Packaging a Conda Environment with Conda-Pack**

.. code-block:: bash

    # Make a folder for storing the conda environments locally
    $ mkdir /opt/jupyterhub/envs

    # Create a new conda environment
    $ conda create -c conda-forge -y -p /opt/jupyterhub/envs/example
    ...

    # Activate the environment
    $ conda activate /opt/jupyterhub/envs/example

    # Install the needed packages
    $ conda install -c conda-forge -y \
    conda-pack \
    jupyterhub-yarnspawner \
    pandas \
    scikit-learn
    ...

    # Pip required to avoid hardcoded path in kernelspec (for now)
    $ pip install notebook

    # Package the environment into example.tar.gz
    $ conda pack -o example.tar.gz
    Collecting packages...
    Packing environment at '/opt/jupyterhub/envs/example' to 'example.tar.gz'
    [########################################] | 100% Completed | 17.9s


**Using the Packaged Environment**

It is recommended to upload the environments to some directory on HDFS
beforehand, to avoid repeating the upload cost for every user. This directory
should be readable by all users, but writable only by the admin user managing
Python environments (here we'll use the ``jupyterhub`` user, and create a
``/jupyterhub`` directory).

.. code-block:: shell

    $ hdfs dfs -mkdir -p /jupyterhub
    $ hdfs dfs -chown jupyterhub /jupyterhub
    $ hdfs dfs -chmod 755 /jupyterhub

Uploading our already packaged environment to hdfs:

.. code-block:: shell

    $ hdfs dfs -put /opt/jupyterhub/envs/example.tar.gz /jupyterhub/example.tar.gz

To use the packaged environment with ``YarnSpawner``, you need to include
the archive in ``YarnSpawner.localize_files``, and activate the environment in
``YarnSpawner.prologue``.

.. code-block:: python

    c.YarnSpawner.localize_files = {
        'environment': {
            'source': 'hdfs:///jupyterhub/example.tar.gz',
            'visibility': 'public'
        }
    }
    c.YarnSpawner.prologue = 'source environment/bin/activate'


Note that we set ``visibility`` to ``public`` for the environment, so that
multiple users can all share the same localized environment (reducing the cost
of moving the environments around).

For more information, see the `Skein documentation on distributing files`_.


Additional Configuration Options
--------------------------------

``YarnSpawner`` has several additional configuration fields. See the
`YarnSpawner documentation`_ for more information on all available options. At
a minimum you'll probably want to configure the memory and cpu limits, as well
as which YARN queue to use.

.. code-block:: python

    # The memory limit for a notebook instance.
    c.YarnSpawner.mem_limit = '2 G'

    # The cpu limit for a notebook instance
    c.YarnSpawner.cpu_limit = 1

    # The YARN queue to use
    c.YarnSpawner.queue = '...'


Example
-------

In summary, an example ``jupyterhub_config.py`` configuration enabling
``yarnspawner`` might look like:

.. code-block:: python

    # Make the JupyterHub internal communication accessible from other machines
    # in the cluster
    c.JupyterHub.hub_ip = ''

    # Enable yarnspawner
    c.JupyterHub.spawner_class = 'yarnspawner.YarnSpawner'

    # Configuration for kerberos security
    c.YarnSpawner.principal = 'jupyterhub'
    c.YarnSpawner.keytab = '/etc/jupyterhub/jupyterhub.keytab'

    # Resource limits per-user
    c.YarnSpawner.mem_limit = '2 G'
    c.YarnSpawner.cpu_limit = 1

    # The YARN queue to use
    c.YarnSpawner.queue = 'jupyterhub'

    # Specify location of the archived Python environment
    c.YarnSpawner.localize_files = {
        'environment': {
            'source': 'hdfs:///jupyterhub/example.tar.gz',
            'visibility': 'public'
        }
    }
    c.YarnSpawner.prologue = 'source environment/bin/activate'


.. _spawner: https://jupyterhub.readthedocs.io/en/stable/reference/spawners.html
.. _YarnSpawner documentation:
.. _yarnspawner: https://jupyterhub-yarnspawner.readthedocs.io/
.. _proxy user: https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/Superusers.html
.. _conda-pack: https://conda.github.io/conda-pack/
.. _conda: http://conda.io/
.. _venv:
.. _virtualenv: https://virtualenv.pypa.io/en/stable/
.. _venv-pack documentation:
.. _venv-pack: https://jcrist.github.io/venv-pack/
.. _YARN resource localization: https://hortonworks.com/blog/resource-localization-in-yarn-deep-dive/
.. _Skein documentation on distributing files: https://jcrist.github.io/skein/distributing-files.html
