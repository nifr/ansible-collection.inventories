# Ansible Collections

* Documentation: https://github.com/ansible-collections/overview
* Collections on Ansible Galaxy: https://galaxy.ansible.com/search?type=collection&order_by=-download_count&page=1
* Official / Community Collections
    * https://galaxy.ansible.com/ansible
    * https://galaxy.ansible.com/community

## Overview 

Create a JSON array of collections and corresponding versions from this repository.

```
mkdir ansible_collections
cd ansible_collections

curl -sSL https://api.github.com/repos/nifr/ansible-collections/tarball/main \
  | tar xzf - --strip-components=1

ANSIBLE_COLLECTIONS_PATH='.' \
ANSIBLE_COLLECTIONS_SCAN_SYS_PATH=0 \
  ansible-galaxy collection list \
    | tail -n +5 \
    | awk -v OFS='\t' '{print $1, $2}' \
    | jq -R '[ split("\t") | {name: .[0], version: .[1]} ]'
```

Example Output:

```
[
  {
    "name": "nifr.inventory_scripts",
    "version": "0.0.1"
  }
]
```

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
pipx install --python=python3.9 --include-deps --force --pip-args='--pre' 'ansible >= 3.0.0, == 3.0.*, < 3.1'
git clone git@github.com:nifr/ansible-collections.git
cd ansible-collections/nifr/inventory_scripts/
ansible-test --sanity --list
ansible-test --sanity --docker default -v
```
