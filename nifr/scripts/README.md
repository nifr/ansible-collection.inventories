# ansible collection - nifr.inventory_scripts

An example collection of Ansible inventory scripts.

## usage

```
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --graph
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --list
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --list --yaml

ANSIBLE_INVENTORY_ENABLED=auto ansible-inventory -i tower_inventory.yml --list

ANSIBLE_INVENTORY_ANY_UNPARSED_IS_FAILED=1 \
ANSIBLE_INVENTORY_ENABLED=awx.awx.tower \
  ansible-inventory \
    -i tower_inventory.yml \
    --list
```

## default inventory script locations

```
/etc/ansible/hosts
/etc/ansible/group_vars/<group_name>[.y[a]ml|json]
/etc/ansible/host_vars/<host_name>[.y[a]ml|json]
```

## list groups and hosts in an inventory

```
ansible-inventory -i <inventory> [--vars] --graph
ansible-inventory -i <inventory> [--yaml|--toml] --list
ansible-inventory -i <inventory> [--yaml|--toml] --host <host>
```

## inventory plugins

Inventory plugins are stored in the `inventory_plugins` directory of a ansible collection.

```
# list inventory plugins
ansible-doc -t inventory -l
# show docs and examples for specific inventory plugin i.e. "script"
ansible-doc -t inventory <plugin name>
```

### inventory resources

* General Help & Issues
  * https://groups.google.com/g/awx-project
  * https://github.com/ansible/awx/issues?q=is%3Aissue+is%3Aopen+inventory
* Documentation
  * https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#
  * https://docs.ansible.com/ansible/latest/plugins/inventory.html#inventory-plugins
  * https://docs.ansible.com/ansible/latest/reference_appendices/config.html#inventory-enabled
  * https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#creating-valid-variable-names
  * https://docs.ansible.com/ansible/devel/user_guide/intro_dynamic_inventory.html
* Inventory Plugins
  * https://docs.ansible.com/ansible/devel/plugins/inventory.html#inventory-plugins
  * https://www.ansible.com/hubfs//AnsibleFest%20ATL%20Slide%20Decks/AnsibleFest%202019%20-%20Managing%20Meaningful%20Inventories.pdf
* Example Scripts & Plugins
  * https://github.com/ansible-collections/community.general/tree/main/scripts/inventory
  * https://github.com/AlanCoding/Ansible-inventory-file-examples/tree/master/plugins
* Collection Search on GitHub
  * https://github.com/topics/ansible-collection
* Example Commits
  * https://github.com/ansible/awx/pull/8650/files
