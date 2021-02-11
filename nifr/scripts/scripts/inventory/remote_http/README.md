# nifr.inventory_scripts.remote_http

## Table of Contents

* [Description](#Description)
* [Configuration](#Configuration)
  * [Variables](#Environment%20Variables)
  * [Additional Information](#Additional%20Information)
* [Usage](#Usage)
  * [Ansible](#Ansible)
  * [awx](#awx)
* [JSON Schema]()
  * [Inventory Response](#Inventory%20Response)
  * [Host Variables Response](#Host%20Variables%20Response)

## Description

A generic dynamic inventory script to request hosts, groups and variables from remote HTTP  endpoints.

This POSIX compliant shell script requests hosts and variables via `GET` requests using `curl`.

The content-type of the HTTP response must be JSON.

The HTTP response body must match ansible's JSON inventory schema.

## Configuration

### Variables

| Environment Variable | Default | Required | Type | Example |
|----------|:-------------:|:--|:-------|:------|
| `HTTP_ENDPOINT_INVENTORY` | - | ✔️ | URL\<string> | `https://example.com/inventory.json` |
| `HTTP_ENDPOINT_HOST_VARS` | - | (✔️) ˟ | URL Template\<string> | `https://example.com/host_vars/`*`%s`*`.json` ˟˟ |
| `HTTP_USER` | - | ❌ | string | `admin` |
| `HTTP_PASSWORD` | - | ❌ | string | `password` |

### Additional Information

|  |  |
|:-|:-|
| **˟** | The endpoint `HTTP_ENDPOINT_HOST_VARS` is queried for every host in the inventory by default.<br />**Warning**: This has a significant performance impact for large inventories.<br /><br />**Recommendation**:<br />In order to prevent this behavior the inventory endpoint must return the host variables (or an empty object) under the `_meta.hostvars` key. (See: [JSON Schema](#JSON%20Schema))<br />In this case `HTTP_ENDPOINT_HOST_VARS` is not required.<br /><br /> Read chapter "[Tuning the external inventory script](https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#tuning-the-external-inventory-script)" in the official documentation for further information. |
| **˟˟** | The sub-string `%s` in `HTTP_ENDPOINT_HOST_VARS` is replaced by the hostname using `printf` during iteration over the list of hosts. |


## Usage

### Ansible

```
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i remote_http.sh --graph
ANSIBLE_INVENTORY_ENABLED=script ansible-inventory -i remote_http.sh --list [--yaml]
```

### awx

1. Create a new "Project" at `/#/projects/add`
    * Enter `Name` -> i.e. "`github.com/nifr/ansible-collections.git`"
    * Select `Source Control Credential Type` -> `Git`
    * Enter `Source Control URL` -> i.e. `github.com:nifr/ansible-collections.git`
1. *(optional)* Create a new "[Credential Type](https://docs.ansible.com/ansible-tower/latest/html/userguide/credential_types.html)" for the HTTP user and password at `/#/credentials`
    * `NAME` -> `HTTP_{USER,PASSWORD}`
    * Input Configuration
        ```
        fields:
          - id: http_user
            type: string
            label: HTTP_USER
          - id: http_password
            type: string
            label: HTTP_PASSWORD
            secret: true
        required:
          - http_user
          - password_password
        ```
    * Injector Configuration
        ```
        env:
          HTTP_USER: '{{ http_user }}'
          HTTP_PASSWORD: '{{ http_password }}'
        ```
1. Create an "Inventory" at `/#/inventories/inventory/add`
1. Add the project as "Inventory Source" at `/#/inventories/inventory/<inventory_id>/sources/add`
    * Select `Source` -> `Sourced From Project`
    * Select `Project` -> *the repositories's awx project*

## JSON Schema

### Inventory Response

Example JSON response from `HTTP_ENDPOINT_INVENTORY` (including host variables).

```
{
    "all": {
        "children": [
            "group1",
            "ungrouped"
        ]
    },
    "group1": {
        "hosts": [
            "host1.example.com",
            "host2.example.com"
        ],
        "vars": {
            "some_variable": "value_for_group1"
        }
    },
    "ungrouped": {
        "hosts": [
            "host3.example.com"
        ]
    },
    "_meta": {
        "hostvars": {
            "host3.example.com": {
                "some_variable": "value_for_host3"
            }
        }
    }
}
```

### Host Variables Response

Example JSON response for `HTTP_ENDPOINT_HOST_VARS`.

```
{
  "some_variable": "value_for_host1.example.com"
}
```
