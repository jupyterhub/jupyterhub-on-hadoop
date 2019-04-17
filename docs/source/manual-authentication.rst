Add Authentication
==================

The last thing we need to do before testing is configure an authenticator_.
JupyterHub has pluggable authentication, and implementations for many common
authentication models already exist. Here we discuss a few that may be of
interest - for more information see JupyterHub's `authenticator docs`_.

Dummy Authenticator
-------------------

The `dummy authenticator`_ is useful for testing purposes, but should *not* be
used in production. It accepts any username and password combination as valid.
To make things *slightly* more secure, you can set a single global shared
password.

We recommend installing this authenticator to test that things are working
before moving on to an actually secure authenticator implementation.

.. code-block:: bash

    # Install the authenticator in JupyterHub's python environment
    $ pip install jupyterhub-dummyauthenticator


.. code-block:: python

    c.JupyterHub.authenticator_class = 'dummyauthenticator.DummyAuthenticator'
    # Optionally add a shared global password to be used by all users
    c.DummyAuthenticator.password = "password-for-testing"


.. _authenticator docs:
.. _authenticator: https://jupyterhub.readthedocs.io/en/stable/reference/authenticators.html
.. _dummy authenticator: https://github.com/jupyterhub/dummyauthenticator
