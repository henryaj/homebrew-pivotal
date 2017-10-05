# services-helpers

Helper scripts for working with Ops Manager environments.

### `pcf_generate_ssh_aliases`

Updates your ssh aliases (at `~/.ssh/config`) with the latest shortcuts for all deployed envs by parsing `london-meta` and `london-services-locks`. Will not remove shortcuts for envs that no longer exist.

### `pcf_target_bosh [env-name]`

Generates SSH aliases, then creates a tunnel onto the OpsMan VM and prints out a command for connecting to the Ops Man-deployed BOSH Director.

### `pcf_ssh_bosh [env-name]`

SSH onto an Ops Man-deployed BOSH Director.
