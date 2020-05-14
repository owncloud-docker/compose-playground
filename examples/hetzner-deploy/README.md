# Hetzner Deployment Scripts

The tools here use terraform to deploy machines into hetzner cloud.
The machines will be accessible via ssh.

## Preconditions

Have access to a project at https://cloud.hetzner.com
Have the public ssh key uploaded, have the private ssh key installed locally.
Have a hcloud API token for your project.
```
  export TF_SSHKEY_NAMES=jw@owncloud.com
  export TF_VAR_hcloud_token=mZdZX......................................................L8bml
```

## scripts

 * `bash ./make_machine.sh` -- creates a machine and returns its IP-ADDR.
    This is a general purpose script, check out the command line options.

 * `bash ./make_ocis_test.sh` -- run ocis as docker compose, with latest phoenix.

 * `bash ./make_ocis_eos_test.sh` -- run ocis with eos

Wait several minutes, until the setup is done.
Follow the instructions on screen.
