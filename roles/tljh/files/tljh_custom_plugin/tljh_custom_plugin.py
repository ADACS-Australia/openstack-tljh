from tljh.hooks import hookimpl
import subprocess
import configparser

# Wrapper for printing to be captured by journalctl
def printf(msg):
    subprocess.check_call(['printf',msg])

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

    msg = 'Editing quota for user: {user}\n'.format(user=username)
    printf(msg)

    try:
        p = subprocess.run(['edquota','-p',quotauser,username], check=True)
        subprocess.check_call(['quota','-us',username])
    except:
        printf(p.stderr)
        msg = 'ERROR in {loc}.\nCould not edit quota for user {user}'.format(loc=__file__,user=username)
        printf(msg)

@hookimpl
def tljh_custom_jupyterhub_config(c):
    import os, nativeauthenticator
    if c.JupyterHub.authenticator_class == "nativeauthenticator.NativeAuthenticator":
        c.JupyterHub.template_paths = ["{}/templates/".format(os.path.dirname(nativeauthenticator.__file__))]
