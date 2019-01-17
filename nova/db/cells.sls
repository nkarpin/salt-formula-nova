{% from "nova/map.jinja" import cfg,cells with context %}

{%- set db_query_params = {} %}
{%- if cfg.get('database', {}).get('x509',{}).get('enabled',False) %}
  {%- do db_query_params.update({'ssl_ca': cfg.database.x509.ca_file, 'ssl_cert': cfg.database.x509.cert_file, 'ssl_key': cfg.database.x509.key_file}) %}
{%- elif cfg.get('database', {}).get('ssl',{}).get('enabled',False) %}
  {%- do db_query_params.update({'ssl_ca': cfg.database.ssl.get('cacert_file', cfg.cacert_file)}) %}
{%- endif %}

# TODO: add ability to set cell0 db url
nova_controller_map_cell0:
  cmd.run:
  - name: nova-manage cell_v2 map_cell0
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}
  - runas: 'nova'

{%- for cell_name, cell in cells.items() %}

nova_{{ cell_name }}_present:
  novav21.cell_present:
    - name: {{ cell.get('name', cell_name) }}
  {%- if cell.database is defined %}
    {%- set cell_db_query_params = {} %}
    {%- if cell.database.get('x509',{}).get('enabled', cfg.get('database', {}).get('x509',{}).get('enabled',False)) %}
      {%- do cell_db_query_params.update({'ssl_ca': cell.database.get('x509',{}).get('ca_file', db_query_params.ssl_ca),
                                          'ssl_cert': cell.database.get('x509',{}).get('cert_file', db_query_params.ssl_cert),
                                          'ssl_key': cell.database.get('x509',{}).get('key_file', db_query_params.ssl_key)}) %}
    {%- elif cell.database.get('ssl',{}).get('enabled', cfg.get('database', {}).get('ssl',{}).get('enabled',False)) %}
      {%- do cell_db_query_params.update({'ssl_ca': cell.database.get('ssl',{}).get('cacert_file', db_query_params.ssl_ca)}) %}
    {%- endif %}
    {%- if cell.database.engine is defined %}
    - db_engine: {{ cell.database.engine }}
    {%- endif %}
    {%- if cell.database.name is defined %}
    - db_name: {{ cell.database.name }}
    {%- endif %}
    {%- if cell.database.user is defined %}
    - db_user: {{ cell.database.user }}
    {%- endif %}
    {%- if cell.database.password is defined %}
    - db_password: {{ cell.database.password }}
    {%- endif %}
    {%- if cell.database.host is defined %}
    - db_address: {{ cell.database.host }}
    {%- endif %}
    {% if cell_db_query_params %}
    - db_query_params:
      {%- for k, v in cell_db_query_params.items() %}
        {{ k }}: {{ v }}
      {%- endfor %}
    {%- endif %}
  {%- endif %}
  {%- if cell.message_queue is defined %}
    {%- if cell.message_queue.user is defined %}
    - messaging_user: {{ cell.message_queue.user }}
    {%- endif %}
    {%- if cell.message_queue.password is defined %}
    - messaging_password: {{ cell.message_queue.password }}
    {%- endif %}
    {%- if cell.message_queue.members is defined or cell.message_queue.host is defined %}
    {% set cell_message_queue_port = cell.message_queue.get('port', '5671' if cell.message_queue.get('ssl',{}).get('enabled', False) else '5672') %}
    - messaging_hosts: {{ cell.message_queue.get('members', [{'host': cell.message_queue.host, 'port': cell_message_queue_port}]) }}
    {%- endif %}
    {%- if cell.message_queue.virtual_host is defined %}
    - messaging_virtual_host: {{ cell.message_queue.virtual_host }}
    {%- endif %}
    - messaging_engine: 'rabbit'
    {% if cell.message_queue.query_params is defined %}
    - messaging_query_params:
      {%- for k, v in cell.message_queue.query_params.items() %}
        {{ k }}: {{ v }}
      {%- endfor %}
    {%- endif %}
  {%- endif %}
  {%- if grains.get('noservices') or cfg.get('role', 'primary') == 'secondary' %}
    - onlyif: /bin/false
  {%- endif %}
    - require:
      - nova_controller_map_cell0

{% endfor %}
