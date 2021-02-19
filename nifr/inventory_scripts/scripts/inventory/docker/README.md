This script was copied from the legacy inventory scripts inside the `community.general` collection ([Link](https://github.com/ansible-collections/community.general/tree/main/scripts/inventory)).

I added the missing `+x` permission to this git repository to make it work with awx.

```
git update-index --chmod=+x scripts/inventory/docker/docker.py
```

The original script requires a running SSH daemon inside the target container with the internal SSH port bind mounted to `0.0.0.0`.

I want to improve/extend this script to return `ansible_connection: docker[_api]` (see: [Non-SSH Connection Types](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#non-ssh-connection-types)) which uses the `docker` CLI or API to execute commands instead.

The docker connection plugins are:

* [`community.docker.docker`](https://docs.ansible.com/ansible/2.10/collections/community/docker/docker_connection.html) (uses Docker CLI)
* [`community.docker.docker_api`](https://docs.ansible.com/ansible/2.10/collections/community/docker/docker_api_connection.html) (uses `docker` python package - see: [pypi.org/project/docker](https://pypi.org/project/docker/))

Another interesting connection plugin is [`community.kubernetes.kubectl`](https://docs.ansible.com/ansible/2.10/collections/community/kubernetes/kubectl_connection.html) which will be the scope of a kubernetes inventory script/plugin (tbd).

Both plugins come with the `ansible` community package (`v3.0.0` as of [2021-02-18](https://www.ansible.com/blog/announcing-the-community-ansible-3.0.0-package)).

Ansible version `2.9.15` that came with awx version `15.0.0` only had the `docker` connection plugin available.

The `community.docker` collection containing the two connection plugins can be installed as follows when using `ansible-(base|core)`:

```
ansible-galaxy collection install community.docker

# list all available connection plugins
ansible-doc -t connection -l

# show docs for the docker connection plugins
ansible-doc -t connection community.docker.docker
ansible-doc -t connection community.docker.docker_api
```

Paired with the docker socket mounted into the `awx_task` container this allows to:

* list all running docker containers as hosts in awx (`#/hosts`)
* manage all containers running on the same host as the `awx_task` container (without adding dynamic inventory parts to a playbook - see example below)
* manage awx itself using an ansible playbook and configurable variables inside the AWX GUI

The overall goal is to create self-managed awx deployments using standard `docker-compose` instead of the "setup" [playbook](https://github.com/ansible/awx/tree/17.0.1/installer).

A (configurable) git repository / branch / tag shall serve as the single source of truth for awx's setup.

Paired with a deployment of a VSCodium service such an awx instance can be administered entirely from a web interface and without any further tooling required.

Example of a dynamic inventory entry via `add_host`:

```
- name: Create a jenkins container
  community.general.docker_container:
    docker_host: myserver.net:4243
    name: my_jenkins
    image: jenkins

- name: Add the container to inventory
  ansible.builtin.add_host:
    name: my_jenkins
    ansible_connection: docker
    ansible_docker_extra_args: "--tlsverify --tlscacert=/path/to/ca.pem --tlscert=/path/to/client-cert.pem --tlskey=/path/to/client-key.pem -H=tcp://myserver.net:4243"
    ansible_user: jenkins
  changed_when: false

- name: Create a directory for ssh keys
  delegate_to: my_jenkins
  ansible.builtin.file:
    path: "/var/jenkins_home/.ssh/jupiter"
    state: directory
```

The host variables returned by the legacy script are similar to a normal docker API query:

```
curl --unix-socket /var/run/docker.sock http://localhost/images/json
```

Example host variables emited by the script:

```
{
  "ansible_ssh_host": "",
  "ansible_ssh_port": 0,
  "docker_name": "/awx_task",
  "docker_short_id": "8f822f2970a29",
  "docker_id": "8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420",
  "docker_created": "2020-12-21T22:56:35.0106701Z",
  "docker_path": "/usr/bin/tini",
  "docker_args": [
    "--",
    "/usr/bin/launch_awx_task.sh"
  ],
  "docker_state": {
    "[..]": "[..]"
  },
  "docker_image": "sha256:125dda56af3301c43fc61f2b157d950110ed70117be4b171a9bce695bd4d6fed",
  "docker_resolvconfpath": "/var/lib/docker/containers/8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420/resolv.conf",
  "docker_hostnamepath": "/var/lib/docker/containers/8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420/hostname",
  "docker_hostspath": "/var/lib/docker/containers/8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420/hosts",
  "docker_logpath": "/var/lib/docker/containers/8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420/8f822f2970a29998dfba96e32f595cc01f23a47fe5b8f59a375afa05ead51420-json.log",
  "docker_restartcount": 0,
  "docker_driver": "overlay2",
  "docker_platform": "linux",
  "docker_mountlabel": "",
  "docker_processlabel": "",
  "docker_apparmorprofile": "",
  "docker_execids": null,
  "docker_hostconfig": {
    "[..]": "[..]"
  },
  "docker_graphdriver": {
    "[..]": "[..]"
  },
  "docker_mounts": [
    "[..]"
  ],
  "docker_config": {
    "[..]": "[..]"
  },
  "docker_networksettings": {
    "[..]": "[..]"
  }
}
```
