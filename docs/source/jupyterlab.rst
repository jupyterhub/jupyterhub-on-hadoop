Use JupyterLab by default
=========================

By default JupyterHub uses the classic Notebook_ frontend. Several alternative
UIs are supported, one of which is JupyterLab_. This provides a more featured
UI, with a whole ecosystem of extensions. It looks like this (borrowed from the
JupyterLab documentation):

.. image:: /_images/jupyterlab_interface.png
    :width: 90 %
    :align: center
    :alt: JupyterLab's modern UI.


Installation
------------

To enable, first install ``jupyterlab`` in the :ref:`notebook environment
<notebook-environments>` *not* the JupyterHub environment.

.. code-block:: shell

    # Install using conda
    $ conda install -c conda-forge jupyterlab

    # Or install with pip
    $ pip install jupyterlab

Next, optionally install the JupyterLab Hub extension into the notebook (not
the JupyterHub) environment. This isn't strictly necessary, but adds a
JupyterHub control panel to the JupyterLab UI allowing easier login/logout.

   .. code-block:: shell

    $ jupyter labextension install @jupyterlab/hub-extension

Finally, configure JupyterHub to start start JupyterLab instead of Jupyter
Notebook by default on startup.

   .. code-block:: python

    # Start users in JupyterLab by default
    c.YarnSpawner.default_url = '/lab'

    # Start JupyterLab with the hub extension (only required if you
    # installed the JupyterLab Hub extension above)
    c.YarnSpawner.cmd = ['python -m yarnspawner.jupyter_labhub']

For more information see the `JupyterLab on JupyterHub`_ and `JupyterLab Hub
Extension`_ documentation.


Useful Extensions
-----------------

JupyterLab has a whole ecsystem of useful extensions. As above, extensions
must be installed in the *notebook* environment to properly work. Below we
list a few that may be useful.

- `Dask Extension <https://github.com/dask/dask-labextension/>`__
- `Interactive Widgets Extension <https://ipywidgets.readthedocs.io/en/stable/user_install.html#installing-the-jupyterlab-extension>`__
- `Git Extension <https://github.com/jupyterlab/jupyterlab-git>`__
- `GitHub Extension <https://github.com/jupyterlab/jupyterlab-github>`__

.. _Notebook: https://jupyter-notebook.readthedocs.io/en/stable/
.. _JupyterLab: https://jupyterlab.readthedocs.io/
.. _JupyterLab on JupyterHub: https://jupyterlab.readthedocs.io/en/stable/user/jupyterhub.html
.. _JupyterLab Hub Extension: https://jupyterlab.readthedocs.io/en/stable/user/jupyterhub.html
