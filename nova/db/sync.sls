{% from "nova/map.jinja" import cfg with context %}

nova_controller_syncdb:
  cmd.run:
  - name: nova-manage db sync
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
