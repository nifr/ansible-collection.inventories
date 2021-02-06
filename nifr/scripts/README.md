# ansible collection - nifr.scripts

An example collection of Ansible inventory scripts.

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