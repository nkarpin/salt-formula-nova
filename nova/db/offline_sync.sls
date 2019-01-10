{% from "nova/map.jinja" import cfg,controller,api with context %}

{%- if controller.get('enabled') or api.get('enabled') %}
  {%- if controller.version not in ["juno", "kilo", "liberty"] %}
nova_controller_sync_apidb:
  cmd.run:
  - name: nova-manage api_db sync
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
  - require_in:
    - nova_controller_syncdb
  {%- endif %}

  {%- if cfg.version not in ["juno", "kilo", "liberty", "mitaka", "newton"] %}
nova_controller_map_cell0:
  cmd.run:
  - name: nova-manage cell_v2 map_cell0
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
  - require:
    - nova_controller_sync_apidb

nova_cell1_create:
  cmd.run:
  - name: nova-manage cell_v2 create_cell --name=cell1 --verbose
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - unless: 'nova-manage cell_v2 list_cells | grep cell1'
  - runas: 'nova'
  - require:
    - nova_controller_map_cell0
  - require_in:
    - nova_controller_syncdb

  {%- endif %}
{%- endif %}

nova_controller_syncdb:
  cmd.run:
  - name: nova-manage db sync
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'