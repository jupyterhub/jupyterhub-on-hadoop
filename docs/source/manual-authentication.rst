Add Authentication
==================

The last thing we need to do before testing is configure an authenticator_.
JupyterHub has pluggable authentication, and implementations for many common
authentication models already exist. Here we discuss a few that may be of
interest - for more information see JupyterHub's `authenticator docs`_.

.. contents:: :local:

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


Kerberos Authenticator
----------------------

The `kerberos authenticator`_ can be used to enable user authentication with
Kerberos_.

.. code-block:: shell

    # Install the authenticator in JupyterHub's python environment
    $ pip install jupyterhub-kerberosauthenticator

Kerberos authentication requires a keytab for the ``HTTP`` service principal
for the host running JupyterHub. Keytabs can be created on the command-line as
follows:

.. code-block:: shell

    $ kadmin -q "addprinc -randkey HTTP/FQDN"
    $ kadmin -q "xst -norandkey -k /etc/jupyterhub/HTTP.keytab HTTP/FQDN"

    # Make the keytab readable/writable only by jupyterhub
    $ chown jupyterhub /etc/jupyterhub/HTTP.keytab
    $ chmod 400 /etc/jupyterhub/HTTP.keytab

where ``FQDN`` is the `fully qualified domain name`_ of the host running
JupyterHub. Alternatively you could include the ``HTTP`` principal in the
keytab created during :ref:`spawner configuration <create-spawner-keytab>`.

The authenticator can then be enabled by adding the following lines to your
``jupyterhub_config.py``:

.. code-block:: python

    c.JupyterHub.authenticator_class = 'kerberosauthenticator.KerberosAuthenticator'
    c.JupyterHub.keytab = '/etc/jupyterhub/HTTP.keytab'

For more information see the `kerberos authenticator docs`_.


LDAP Authenticator
------------------

The `LDAP authenticator`_ can be used to authenticate with LDAP_ or `Active
Directory`_. An example install and configuration might look like:

.. code-block:: shell

    # Install the authenticator in JupyterHub's python environment
    $ pip install jupyterhub-ldapauthenticator

.. code-block:: python

    c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
    c.LDAPAuthenticator.server_address = 'address.of.your.ldap.server'
    c.LDAPAuthenticator.bind_dn_template = 'cn={username},ou=edir,ou=people,ou=EXAMPLE-UNIT,o=EXAMPLE'

See the ldapauthenticator_ documentation for more information.


Remote User Authenticator
-------------------------

The `remote user authenticator`_ makes use of the ``REMOTE_USER`` header for
authentication. This allows use of JupyterHub with an external authenticating
proxy (such as `Apache Knox`_).

.. code-block:: shell

    # Install the authenticator in JupyterHub's python environment
    $ pip install jhub_remote_user_authenticator

.. code-block:: python

    c.JupyterHub.authenticator_class = 'jhub_remote_user_authenticator.remote_user_auth.RemoteUserAuthenticator'

For more information see the `remote user authenticator docs`_.


.. _authenticator docs:
.. _authenticator: https://jupyterhub.readthedocs.io/en/stable/reference/authenticators.html
.. _dummy authenticator: https://github.com/jupyterhub/dummyauthenticator
.. _kerberos authenticator:
.. _kerberos authenticator docs: https://jupyterhub-kerberosauthenticator.readthedocs.io/
.. _Kerberos: https://web.mit.edu/kerberos/
.. _fully qualified domain name: https://en.wikipedia.org/wiki/Fully_qualified_domain_name
.. _LDAP authenticator:
.. _ldapauthenticator: https://github.com/jupyterhub/ldapauthenticator
.. _LDAP: https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
.. _Active Directory: https://en.wikipedia.org/wiki/Active_Directory
.. _remote user authenticator:
.. _remote user authenticator docs: https://github.com/cwaldbieser/jhub_remote_user_authenticator
.. _Apache Knox: https://knox.apache.org/
