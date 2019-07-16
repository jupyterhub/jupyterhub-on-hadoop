import alabaster

# Project settings
project = 'JupyterHub on Hadoop'
copyright = '2019, Jim Crist'
author = 'Jim Crist'
release = version = '0.1.0'

source_suffix = '.rst'
master_doc = 'index'
language = None
pygments_style = 'sphinx'
exclude_patterns = []

# Sphinx Extensions
extensions = ['sphinx.ext.extlinks']

numpydoc_show_class_members = False

extlinks = {
    'issue': ('https://github.com/jupyterhub/jupyterhub-on-hadoop/issues/%s', 'Issue #'),
    'pr': ('https://github.com/jupyterhub/jupyterhub-on-hadoop/pull/%s', 'PR #')
}

# Sphinx Theme
html_theme = 'alabaster'
html_theme_path = [alabaster.get_path()]
templates_path = ['_templates']
html_static_path = ['_static']
html_theme_options = {
    'description': 'Documentation for deploying JupyterHub on a Hadoop Cluster',
    'github_button': True,
    'github_count': False,
    'github_user': 'jupyterhub',
    'github_repo': 'jupyterhub-on-hadoop',
    'travis_button': False,
    'show_powered_by': False,
    'page_width': '960px',
    'sidebar_width': '250px',
    'code_font_size': '0.8em'
}
html_sidebars = {
    '**': ['about.html',
           'navigation.html',
           'help.html',
           'searchbox.html']
}
