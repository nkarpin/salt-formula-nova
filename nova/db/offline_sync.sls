{% from "nova/map.jinja" import controller,cells_params with context %}

{%- if controller.version not in ["juno", "kilo", "liberty"] and controller.get('api', {}).get('enabled', True) %}
nova_controller_sync_apidb:
  cmd.run:
  - name: nova-manage api_db sync
  {%- if grains.get('noservices') or controller.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
  - require_in:
    - nova_controller_syncdb

{%- endif %}

{%- if controller.version not in ["juno", "kilo", "liberty", "mitaka", "newton"] and controller.get('api', {}).get('enabled', True) %}
{%- set cells = controller.cells %}

nova_controller_map_cell0:
  cmd.run:
  {%- if cells_params.cell0 is defined %}
    {%- if cells_params.cell0.connection is defined %}
  - name: nova-manage cell_v2 map_cell0 --database_connection {{ cells_params.cell0.connection }}
    {%- endif %}
    {%- do cells_params.pop('cell0') %}
  {%- else %}
  - name: nova-manage cell_v2 map_cell0
  {%- endif %}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
  - require:
    - nova_controller_sync_apidb

  {%- for cell_name, cell in cells_params.items() %}
    {%- set cell_args = '--name=' + cells[cell_name].get('name', cell_name) %}
    {%- if cells_params[cell_name].transport_url is defined %}
      {%- set cell_args = cell_args + ' --transport-url ' + cells_params[cell_name].transport_url %}
    {%- endif %}
    {%- if cells_params[cell_name].connection is defined %}
      {%- set cell_args = cell_args + ' --database_connection ' + cells_params[cell_name].connection %}
    {%- endif %}

nova_{{ cell_name }}_create:
  cmd.run:
  - name: nova-manage cell_v2 create_cell --verbose {{ cell_args }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - unless: 'nova-manage cell_v2 list_cells | grep {{ cell_name }}'
  - runas: 'nova'
  - require:
    - nova_controller_map_cell0
  - require_in:
    - nova_controller_syncdb

  {%- endfor %}

{%- endif %}

nova_controller_syncdb:
  cmd.run:
  - name: nova-manage db sync
  {%- if grains.get('noservices') or controller.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
