{% from "nova/map.jinja" import cfg with context %}

nova_sync_apidb:
  cmd.run:
  - name: nova-manage api_db sync
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'