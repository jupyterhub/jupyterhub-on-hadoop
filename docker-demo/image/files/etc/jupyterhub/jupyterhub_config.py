import os

# Basic setup
c.JupyterHub.bind_url = 'http://:8888'
c.JupyterHub.cookie_secret_file = '/etc/jupyterhub/jupyterhub_cookie_secret'
c.JupyterHub.db_url = 'sqlite:////var/jupyterhub/jupyterhub.sqlite'

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

# Activate the JupyterHub conda environment
c.YarnSpawner.prologue = 'source /opt/jupyterhub/miniconda/bin/activate'

authenticator = os.environ.get('JHUB_AUTHENTICATOR', 'dummy').lower()
if authenticator == 'kerberos':
    c.JupyterHub.authenticator_class = 'kerberosauthenticator.KerberosAuthenticator'
    c.KerberosAuthenticator.keytab = '/etc/jupyterhub/jupyterhub.keytab'
else:
    c.JupyterHub.authenticator_class = 'dummyauthenticator.DummyAuthenticator'
    c.DummyAuthenticator.password = "testpass"
    # A whitelist of valid usernames. The kerberosauthenticator will enforce
    # only valid users are logged in, but the dummyauthenticator has no such
    # mechanism so we need to rely on a whitelist
    c.DummyAuthenticator.whitelist = [
        'alice',
        'bob',
        'carl'
    ]
