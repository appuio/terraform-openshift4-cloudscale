locals {
  anti_affinity_capacity    = 4
  anti_affinity_group_count = ceil(var.node_count / local.anti_affinity_capacity)

  user_data = [
    for hostname in random_id.node[*].hex :
    {
      "ignition" : {
        "version" : "3.2.0",
        "config" : {
          "merge" : [{
            "source" : "https://${var.api_int}:22623/config/${var.ignition_config}"
          }]
        },
        "security" : {
          "tls" : {
            "certificateAuthorities" : [{
              "source" : "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition_ca)}"
            }]
          }
        }
      },
      "systemd" : {
        "units" : [
          {
            "name" : "cloudscale-hostkeys.service",
            "enabled" : true,
            "contents" : <<-EOC
            [Unit]
            Description=Print SSH Public Keys to tty
            After=sshd-keygen.target

            [Install]
            WantedBy=multi-user.target

            [Service]
            Type=oneshot
            StandardOutput=tty
            TTYPath=/dev/ttyS0
            ExecStart=/bin/sh -c "echo '-----BEGIN SSH HOST KEY KEYS-----'; cat /etc/ssh/ssh_host_*key.pub; echo '-----END SSH HOST KEY KEYS-----'"
            EOC
          },
          {
            "name": "kubelet.service",
            "dropins": [
              {
                "name": "appuio-provider-id.conf",
                "contents": <<-EOC
                # Managed through terraform-openshift4-cloudscale
                [Service]
                ExecStartPre=/bin/bash -c \
                  'echo "KUBELET_PROVIDERID=\"cloudscale://$(curl http://169.254.169.254/openstack/2017-02-22/meta_data.json | \
                    jq -r .meta.cloudscale_uuid)\"" > /run/appuio-provider-id.env'
                EnvironmentFile=-/run/appuio-provider-id.env
                EOC
              }
            ]
          }
        ]
      },
      "storage": {
        "files": [
          {
            "path": "/etc/hostname",
            "mode": 420,
            "contents": {
              "source": "data:,${hostname}"
            }
          }
        ]
      }
    }
  ]
}

resource "random_id" "node" {
  count       = var.node_count
  prefix      = "${var.role}-"
  byte_length = 2
}

resource "cloudscale_server_group" "nodes" {
  count     = var.node_count != 0 ? local.anti_affinity_group_count : 0
  name      = "${var.role}-group"
  type      = "anti-affinity"
  zone_slug = "${var.region}1"
}

resource "cloudscale_server" "node" {
  count            = var.node_count
  name             = "${random_id.node[count.index].hex}.${var.node_name_suffix}"
  zone_slug        = "${var.region}1"
  flavor_slug      = var.flavor_slug
  image_slug       = var.image_slug
  server_group_ids = var.node_count != 0 ? [cloudscale_server_group.nodes[floor(count.index / local.anti_affinity_capacity)].id] : []
  volume_size_gb   = var.volume_size_gb
  interfaces {
    type = "private"
    addresses {
      subnet_uuid = var.subnet_uuid
    }
  }
  user_data = jsonencode(local.user_data[count.index])

  lifecycle {
    ignore_changes = [
      skip_waiting_for_ssh_host_keys,
      image_slug,
      user_data,
      volume_size_gb,
    ]
  }
}
