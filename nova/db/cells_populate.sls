nova_controller_discover_hosts:
  cmd.run:
  - name: nova-manage cell_v2 discover_hosts --verbose
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'

nova_controller_map_instances:
  novang.map_instances:
  - name: 'cell1'
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - cmd: nova_controller_discover_hosts