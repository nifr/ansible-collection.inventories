# ansible collection - nifr.scripts

An example collection of Ansible inventory scripts.

## usage

```
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --graph
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --list
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i scripts/inventory/remote_http/remote_http.sh --list --yaml

ANSIBLE_INVENTORY_ENABLED=auto ansible-inventory -i tower_inventory.yml --list
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
