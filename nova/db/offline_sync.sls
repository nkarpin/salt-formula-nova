{% from "nova/map.jinja" import cfg,controller,api,cells with context %}

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

  {%- set db_query_params = {} %}
  {%- if cfg.get('database', {}).get('x509',{}).get('enabled',False) %}
    {%- do db_query_params.update({'ssl_ca': cfg.database.x509.ca_file, 'ssl_cert': cfg.database.x509.cert_file, 'ssl_key': cfg.database.x509.key_file}) %}
  {%- elif cfg.get('database', {}).get('ssl',{}).get('enabled',False) %}
    {%- do db_query_params.update({'ssl_ca': cfg.database.ssl.get('cacert_file', cfg.cacert_file)}) %}
  {%- endif %}

    {%- for cell_name, cell in cells.items() %}
      {%- set cell_db_query_params = {} %}
      {%- if cell.database.get('x509',{}).get('enabled', cfg.get('database', {}).get('x509',{}).get('enabled',False)) %}
        {%- do cell_db_query_params.update({'ssl_ca': cell.database.get('x509',{}).get('ca_file', db_query_params.ssl_ca),
                                            'ssl_cert': cell.database.get('x509',{}).get('cert_file', db_query_params.ssl_cert),
                                            'ssl_key': cell.database.get('x509',{}).get('key_file', db_query_params.ssl_key)}) %}
      {%- elif cell.database.get('ssl',{}).get('enabled', cfg.get('database', {}).get('ssl',{}).get('enabled',False)) %}
        {%- do cell_db_query_params.update({'ssl_ca': cell.database.get('ssl',{}).get('cacert_file', db_query_params.ssl_ca)}) %}
      {%- endif %}

      {% set cell_message_queue_port = cell.message_queue.get('port', '5671' if cell.message_queue.get('ssl',{}).get('enabled', False) else '5672') %}

nova_{{ cell_name }}_present:
  novav21.cell_present:
    - name: {{ cell.get('name', cell_name) }}
    - db_engine: {{ cell.database.engine }}
    - db_name: {{ cell.database.name }}
    - db_user: {{ cell.database.user }} 
    - db_password: {{ cell.database.password }}
    - db_address: {{ cell.database.host }}
      {% if cell_db_query_params %}
    - db_query_params:
        {%- for k, v in cell_db_query_params.items() %}
        {{ k }}: {{ v }}
        {%- endfor %}
      {%- endif %}
    - messaging_user: {{ cell.message_queue.user }}
    - messaging_password: {{ cell.message_queue.password }}
    - messaging_hosts: {{ cell.message_queue.get('members', [{'host': cell.message_queue.host, 'port': cell_message_queue_port}]) }}
    - messaging_virtual_host: {{ cell.message_queue.virtual_host }}
    - messaging_engine: 'rabbit'
      {% if cell.message_queue.query_params is defined %}
    - messaging_query_params:
        {%- for k, v in cell.message_queue.query_params.items() %}
        {{ k }}: {{ v }}
        {%- endfor %}
      {%- endif %}
      {%- if grains.get('noservices') %}
    - onlyif: /bin/false
      {%- endif %}
    - require:
      - nova_controller_map_cell0
    - require_in:
      - nova_controller_syncdb

    {%- endfor %}

  {%- endif %}

{%- endif %}

nova_controller_syncdb:
  cmd.run:
  - name: nova-manage db sync
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'
