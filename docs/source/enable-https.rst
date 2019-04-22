Enabling HTTPS
==============

While JupyterHub runs fine with just HTTP, we highly recommend enabling SSL
encryption (HTTPS). You can either have JupyterHub handle its own SSL
termination, or run JupyterHub behind a proxy and handle SSL termination
externally. For more information, see the `JupyterHub documentation`_.

Handling SSL termination in JupyterHub
--------------------------------------

If you have your own SSL certificates you can have JupyterHub handle SSL
termination itself. To do so, you need to specify their locations in your
``jupyterhub_config.py``:

.. code-block:: python

    c.JupyterHub.ssl_cert = '/path/to/your.cert'
    c.JupyterHub.ssl_key = '/path/to/your.key'

If your cert file also contains the key (which is sometimes true), you can omit
setting ``ssl_key``.

You'll also need to change any configuration fields that you set to use
``http`` to ``https`` (typically this is just ``bind_url``):

.. code-block:: python

    c.JupyterHub.bind_url = 'https://:<PORT-TO-USE>'

Just as with kerberos keytabs, it is important to put
these files in a secure location on your server where they are not readable by
regular users. In the absence of a better location, we recommend
``/etc/jupyterhub/``.

.. code-block:: shell

    $ mv mycert.cert /etc/jupyterhub/jupyterhub.cert
    $ mv mykey.key /etc/jupyterhub/jupyterhub.key
    $ chmod 400 /etc/jupyterhub/jupyterhub.cert /etc/jupyterhub/jupyterhub.key
    $ chown jupyterhub /etc/jupyterhub/jupyterhub.cert /etc/jupyterhub/jupyterhub.key

Using external SSL termination
------------------------------

If JupyterHub is running behind a reverse proxy that already handles SSL
termination (NGINX, etc...), you can omit configuring ``ssl_cert`` and
``ssl_key``. No further steps are necessary.

.. _JupyterHub documentation: https://jupyterhub.readthedocs.io/en/stable/getting-started/security-basics.html#enabling-ssl-encryption
