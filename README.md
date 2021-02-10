# Ansible Collections

* Documentation: https://github.com/ansible-collections/overview
* Collections on Ansible Galaxy: https://galaxy.ansible.com/search?type=collection&order_by=-download_count&page=1
* Official / Community Collections
    * https://galaxy.ansible.com/ansible
    * https://galaxy.ansible.com/community

## Installation from git

Add a `requirements.yml` to your playbook directory.

```
---
roles: []

collections:
  - name: nifr.inventory_scripts
    type: git
    version: main
    source: git+https://github.com/nifr/ansible_collections.git#/nifr/inventory_scripts/
```

Now install the dependencies with the `ansible-galaxy` command.

```
ansible-galaxy install -r requirements.yml
```

## Testing a collection

```
pipx install [--suffix '@2.10-python3.7'] --python python3.7 --include-deps --force 'ansible >= 2.10.0, == 2.10.*, < 2.11'
git clone git@github.com:nifr/ansible-collections.git
cd ansible-collections/nifr/inventory_scripts/
ansible-test --sanity --list
ansible-test --sanity --docker default -v
```

## Issues

YAML linting is skipped during sanity testing.

> WARNING: Skipping sanity test 'yamllint' due to missing libyaml support in PyYAML.

The `pipx --suffix [..]` installation doesn't work with ansible commands.

> ERROR! Unknown Ansible alias: ansible@2.10-python3.7

The `ansible-test [..]` command only works in very concrete directory structures.

> ERROR: The current working directory must be at or below:
>
> - an Ansible collection: {...}/ansible-collections/{namespace}/{collection}/
>
> Current working directory: /mnt/c/Users/nifr/code/ansible_collections/nifr
