# Hetzner Deployment Scripts

The tools here can use terraform to deploy machines into Hetzner cloud.
The machines will be accessible via ssh then.

Alternatively you can deploy into existing machines, using either:

 * `export OC_DEPLOY_ADDR=xx.yy.zz.aa` -- this will use `ssh root@$OC_DEPLOY_ADDR` to access the macine. Your ssh-key should be installed at the root account.

 * `export OC_DEPLOY_ADDR=localhost` -- this will use `sudo` to install locally.


## Preconditions for Using Hetzner Cloud

Have access to a project at https://console.hetzner.cloud
Have the public ssh key uploaded, have the private ssh key installed locally.
Have a hcloud API token for your project.
```
  export TF_SSHKEY_NAMES=jw@owncloud.com
  export TF_VAR_hcloud_token=mZdZX......................................................L8bml
```
If you don't have a token, you can create a machine manually at the web interface. Always include your ssh-key when you do that.
Then you can provide its IP address via OC_DEPLOY_ADDR.


## Scripts

All these scripts are independant entry points. Each of them fires up a new hetzner machine 
and deploys a specific setup there (or at least does it half way and gives instruction for what to do next).

 * `./make_ocis_eos_docker_test.sh` -- run ocis with eos aarnet style

 * `./make_ocis_test.sh` -- run ocis as docker compose, with latest phoenix.

 * `./make_ocis_eos_test.sh` -- run ocis with old style CERN eos

 * `./make_aarnet_eos.sh` -- run an eos setup, but no ocis there yet. 

 * `./make_machine.sh` -- creates a machine and returns its IP address.
   This is a general purpose script, check out the command line options.
   In case of OC_DEPLOY_ADDR=localhost, an attempt is made to return the IP address associated with the default route.
   The other scripts are actually wrappers on this one. Read and modify them. (But don't read make_machine.sh -- it does magic).

In each case, wait several minutes, until the setup is done.
Follow the instructions on screen.

You can tear down a Hetzner machines either from https://console.hetzner.cloud, or by using the command line.
In both cases, you will be prompted with the machine name again, and will have to confirm.

  * `./destroy_machine.sh MACHINE_NAME` -- destroy one specific machine.
  
  * `./destroy_machine.sh "$USER-*"` -- destroy all machines prefixed with my user name. At the prompts you can say `yes` or `no` to select which ones to actually destroy.
  .
  * `./destroy_machine.sh` -- without parameters, it returns a listing of running machines that were made with make_machine.sh
