# STEPS

## 1. Building the image
The image is built using packer on the Nectar OpenStack cloud service.

Load your openstack credentials
```
source my-project-openrc.sh
```
Build the image (takes ~15 mins)
```
packer build packer.json
```
You should now have an image named `TheLittlestJupyterHub` available to your OpenStack project.

## 2. Launch server
- Launch a large-ish server with this image.
- Make sure you can access it via SSH.
- Make sure it has port security that allows ICMP (ping), HTTP, and HTTPS.

## 3. Domain name
Register a domain name for your server by creating a DNS record (see e.g. https://supercomputing.swin.edu.au/rcdocs/dns/).

## 4. Certify your server to enable secure connections via HTTPS
The ansible playbook `certify.yml` automates all the necessary steps to certify your server with a LetsEncrypt certificate.
It has two required inputs:
1. `domain` - the domain name for your server
2. `email` - the email address you wish to use for registering with LetsEncrypt

First you should make a basic ansible inventory with connection details to your machine. e.g.
```
all:
  hosts:
    tljh:
      ansible_host: 136.186.111.111
      ansible_user: ubuntu
```

You can then run the playbook on your machine via
```
ansible-playbook -i inventory.yml certify.yml --extra-vars "domain=<DOMAIN> email=<EMAIL>"
```

Your server should then be available at `https://<DOMAIN>`.


# Useful stuff (once the server is up)

## Creating the 1st admin user
To create the very first admin user, you must SSH into the machine, then register an admin username in the configuration
```
sudo tljh-config add-item auth.NativeAuthenticator.admin_users <admin-username>
sudo tljh-config reload
```
Back on the login page,
- click on `Signup!`
- use the `<admin-username>` you chose above + a password, click `Create User`
- click `Login!`, enter your username and password, and you should have immediate access without having to be authorized.


## Authorizing a non-admin user
All users must sign up. Before they can login however, they must be *authorized* by an admin user (unless they have been previously declared as an admin user).
Admin users should navigate to `<jupyterhub-url>/hub/authorize` to authorize users (you cannot navigate to this via the webpage, you must manually enter the URL).


## Installing packages
You can either SSH directly into the machine, or login as an admin and open a web terminal. Conda is installed as root, so most commands will require `sudo`. Remember to use `-E` with `sudo` to preserve the current environment variables (otherwise conda will fail).

To install packages into the base/main environment
```
sudo -E conda install <package(s)>
```

To install packages into another environment
```
sudo -E conda install -n <env> <package(s)>
```

To create a new environment with some packages
```
sudo -E conda create -n my_new_env python=3.8 numpy astropy ipykernel
```
Remember to make sure ipykernel is installed in each of the environments that you wish to be visible as a usable kernel.


## Sharing material with other users
Admin users can upload files to the `shared` directory to distribute material easily. This directory is visible to all users, but only writeable by admins.


## Changing your password
Users that are logged in the system can easily change their password by going to: `<jupyterhub-url>/hub/change-password`.


## Changing config options/limits
Examples
```
sudo tljh-config set limits.memory 24G
sudo tljh-config set limits.cpu 4
sudo tljh-config set auth.type nativeauthenticator.NativeAuthenticator
sudo tljh-config set auth.NativeAuthenticator.check_common_password False
sudo tljh-config set auth.NativeAuthenticator.minimum_password_length 20
sudo tljh-config reload
```
Remember to reload the configuration for changes to take effect.


## Quotas
To report the quota for all users
```
sudo repquota -sa
```

To set the quota for a particular user (e.g. `quotauser`)
```
sudo setquota -u quotauser 2G 2G 0 0 /
```

To apply the quota set on `quotauser` to `another-user`
```
sudo edquota -p quotauser another-user
```

If you want to change the quota limit, you must do it manually for all existing users using one of the methods above. For new users, changing the quota for `quotauser` should be sufficient.


## References
- https://tljh.jupyter.org/en/latest/
- https://native-authenticator.readthedocs.io/en/latest/quickstart.html


# Generic notes on setup/configuration/defaults

- The latest `certbot` is installed via `snap`.
- User and group quotas (journaled) are enabled.
- In order to apply disk quotas to newly created users, a custom TLJH plugin/hook is installed that calls `edquota -p <QUOTAUSER> <new-user>`. This applies the quota set on `QUOTAUSER` to the new user. `QUOTAUSER` is defined in `/etc/adduser.conf`, and is also done if users are manually created with the `adduser` command. (TLJH creates users with the lower level command `useradd`, which does not apply quotas).
- By default, `QUOTAUSER=quotauser`, and has a 2GB hard limit (both on users and groups).
- Some `jupyterhub.service` configuration options are overridden in `/etc/systemd/system/jupyterhub.service.d/override.conf` to allow the service to access `/dev`. This is necessary for `edquota` to work, since it resolves to mount point `/` to `/dev/vda1`.
- TLJH is installed with:
  - no default user(s)
  - the Native Authenticator
  - a minimum password length of 6
  - a 24GB memory limit, and
  - 4 CPU limit.
- Each of the above options are configurable.
- TLJH also comes installed with `nb_conda_kernels`, to allow conda environments to show up as available kernels to use. Each conda env you want to show up must have `ipykernel` installed.
- The naming scheme for conda envs/kernels is modified in `/usr/local/etc/jupyter/jupyter_config.json` to be cleaner.
- Three additional conda envs are installed (py37, py38, py39), each with numpy, scipy, matplotlib, astropy, and ipykernel.
- The base conda environment is activated on login (via SSH) for convenience.
- A `shared` directory is added to every users' home directory. It is readable by everyone, and writable by users in the `jupyterhub-admins` group.
