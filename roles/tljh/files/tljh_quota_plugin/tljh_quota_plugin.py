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

    subprocess.run(['edquota','-p',quotauser,username],check=True, shell=True)
