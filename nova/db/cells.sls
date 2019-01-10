{% from "nova/map.jinja" import cfg with context %}

nova_controller_map_cell0:
  cmd.run:
  - name: nova-manage cell_v2 map_cell0
  {%- if grains.get('noservices') %} or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'

nova_cell1_create:
  cmd.run:
  - name: nova-manage cell_v2 create_cell --name=cell1 --verbose
  {%- if grains.get('noservices') %} or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - unless: 'nova-manage cell_v2 list_cells | grep cell1'
  - runas: 'nova'
  - require:
    - nova_controller_map_cell0