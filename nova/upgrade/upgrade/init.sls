{%- from "nova/map.jinja" import controller, compute, compute_driver_mapping with context %}

nova_upgrade:
  test.show_notification:
    - name: "dump_message_upgrade_nova"
    - text: "Running nova.upgrade.upgrade"

include:
 - nova.upgrade.service_stopped
 - nova.upgrade.pkgs_latest
 - nova.upgrade.render_config
{%- if controller.get('enabled', False) %}
 - nova.db.offline_sync
{%- endif %}
 - nova.upgrade.service_running
