## Installation from Ansible Galaxy

```
ansible-galaxy collection install nifr.<collection_name>
```

The installation path is the first existing directory in Ansible's [collections path](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths) (added in v2.10).

The collections path is configured using the environment variable `ANSIBLE_COLLECTIONS_PATH` or in `ansible.cfg`:

```
[defaults]
collections_path = ~/.ansible/collections:/usr/share/ansible/collections
```

The default path is `~/.ansible/collections/ansible_collections/nifr/<collection_name>/`.

## Installation from git

```
ansible-galaxy collection install git+https://github.com/nifr/ansible-collections.git#/nifr/<collection_name>,main
```

## Installation from git with requirements.yml

Add a `requirements.yml` to your playbook directory.

```
---
roles: []

collections:
  - name: nifr.inventory_scripts
    type: git
    version: main
    source: git+https://github.com/nifr/ansible_collections.git#/nifr/<collection_name>/
```

Now install the dependencies with the `ansible-galaxy` command.

```
ansible-galaxy install -r requirements.yml
```

## Testing a collection

Ansible's official test tool `ansible-test` was released with ansible 2.9. (See: [tests directory](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html#tests-directory), [Testing Collections](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html#testing-collections))

```
pipx install --python=python3.9 --include-deps --force --pip-args='--pre' 'ansible >= 3.0.0, == 3.0.*, < 3.1'
git clone git@github.com:nifr/ansible-collections.git ansible_collections
cd ansible_collections/nifr/<collection_name>/
ansible-test --sanity --list
ansible-test --sanity --docker default -v
```

## Maintenance

### List of Collections in this Repository

Create a JSON array of collections and current versions from this repository.

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
    "name": "nifr.<collection_name>",
    "version": "0.0.1"
  }
]
```

# Further Information

* Documentation: https://github.com/ansible-collections/overview
* Collections on Ansible Galaxy: https://galaxy.ansible.com/search?type=collection&order_by=-download_count&page=1
* Official / Community Collections
    * https://galaxy.ansible.com/ansible
    * https://galaxy.ansible.com/community
