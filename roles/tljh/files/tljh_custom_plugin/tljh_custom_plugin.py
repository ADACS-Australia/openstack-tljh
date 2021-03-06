from tljh.hooks import hookimpl
import subprocess
import configparser

@hookimpl
def tljh_new_user_create(username):
    c = configparser.ConfigParser()

    with open('/etc/adduser.conf','r') as f:
        s = f.read()

    # Add a fake section heading so that config parser can read it
    s = '[adduser]\n' + s

    try:
        c.read_string(s)
        quotauser = c['adduser']['QUOTAUSER'].strip('\"')
    except:
        quotauser = 'quotauser'

    try:
        p = subprocess.run(['edquota','-f','/','-p',quotauser,username], check=True)
        print(p.stdout)
    except:
        print(p.stderr)

@hookimpl
def tljh_custom_jupyterhub_config(c):
    import os, nativeauthenticator
    if c.JupyterHub.authenticator_class == "nativeauthenticator.NativeAuthenticator":
        c.JupyterHub.template_paths = ["{}/templates/".format(os.path.dirname(nativeauthenticator.__file__))]
