# STEPS

Uses ansible playbook from git submodule https://github.com/ADACS-Australia/murano-jupyterhub

## 1. Building the image
The image is built using packer on the Nectar OpenStack cloud service.

Load your openstack credentials
```
source my-project-openrc.sh
```
Build the image (takes ~15 mins)
```
./build.sh
```
You should now have an image named `ADACS The Littlest JupyterHub (Ubuntu 22.04 LTS Focal)` (or whatever you set in the build script) available to your OpenStack project. If you are rebuilding the image, you may need to remove the existing one before you run `packer build`.

## 2. Launch server
- Launch a large-ish server with this image.
- Make sure you can access it via SSH.
- Make sure it has port security that allows ICMP (ping), HTTP, and HTTPS.

## 3. Domain name
Register a domain name for your server by creating a DNS record (see e.g. https://supercomputing.swin.edu.au/rcdocs/dns/).

## 4. Certify your server to enable secure connections via HTTPS
Now that you have a domain name, SSH into your machine and run the following commands to register your server with an HTTPS certificate using an email address
```
sudo tljh-config set https.enabled true
sudo tljh-config add-item https.letsencrypt.domains <DOMAIN>
sudo tljh-config set https.letsencrypt.email <EMAIL>
sudo tljh-config reload proxy
sudo tljh-config reload hub
```

Your server should then be available at `https://<DOMAIN>`.


# Useful stuff (once the server is up)
See https://github.com/ADACS-Australia/ansible-jupyterhub#useful-stuff-once-the-server-is-up
