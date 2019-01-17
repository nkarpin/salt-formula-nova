{% from "nova/map.jinja" import cfg,cells with context %}

nova_controller_discover_hosts:
  cmd.run:
  - name: nova-manage cell_v2 discover_hosts --verbose
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'

{%- for cell_name, cell in cells.items() %}
nova_controller_map_instances_{{ cell_name }}:
  novav21.instances_mapped_to_cell:
  - name: {{ cell.get('name', cell_name) }}
  - timeout: {{ cell.get('instances_map_timeout', '60') }}
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
{% endfor %}