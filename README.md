# services-helpers

Helper scripts for working with Ops Manager environments.

## `generate_ssh_aliases`

Updates your ssh aliases (at `~/.ssh/config`) with the latest shortcuts for all deployed envs by parsing `london-meta` and `london-services-locks`. Will not remove shortcuts for envs that no longer exist.

## `target_opsman_bosh`

`target_opsman_bosh [env-name, e.g. carrotcake]`

Runs `generate_ssh_aliases` as above, then creates a tunnel onto the OpsMan VM and prints out a command for connecting to the OpsMan-deployed BOSH Director.
