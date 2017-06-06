# services-helpers

Helper scripts for working with Ops Manager environments.

## `generate_ssh_aliases.rb`

Will update your ssh aliases (at `~/.ssh/config`) with the latest shortcuts for all deployed envs by parsing `london-meta` and `london-services-locks`. Will not remove shortcuts for envs that no longer exist.
