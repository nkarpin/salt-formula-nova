{% from "nova/map.jinja" import cfg,controller with context %}

include:
  - nova.api
  - nova.conductor
  - nova.scheduler
{%- if cfg.version not in ["juno", "kilo", "liberty", "mitaka", "newton"] %}
  - nova.placement
{%- endif %}
  - nova.consoleproxy
{% if cfg.version in ["juno", "kilo", "liberty", "mitaka", "newton", "ocata", "pike", "queens"] %}
  - nova.consoleauth
{%- endif %}
{% if cfg.version in ["juno", "kilo", "liberty", "mitaka"] %}
  - nova.cert_service
{%- endif %}
{%- if cfg.version not in ["juno", "kilo", "liberty", "mitaka", "newton"] %}
  - nova.db.cells_populate
{%- endif %}

{%- if cfg.version not in ["juno", "kilo", "liberty", "mitaka", "newton"] %}
{%- if cfg.get('update_cells') %}

nova_update_cell0:
  novang.update_cell:
  - name: "cell0"
  - db_name: {{ cfg.database.name }}_cell0
  - db_engine: {{ cfg.database.engine }}
  - db_password: {{ cfg.database.password }}
  - db_user: {{ cfg.database.user }}
  - db_address: {{ cfg.database.host }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- set rabbit_port = cfg.message_queue.get('port', 5671 if cfg.message_queue.get('ssl',{}).get('enabled', False) else 5672) %}

nova_update_cell1:
  novang.update_cell:
  - name: "cell1"
  - db_name: {{ cfg.database.name }}
{%- if cfg.message_queue.members is defined %}
  - transport_url: rabbit://{% for member in cfg.message_queue.members -%}
                             {{ cfg.message_queue.user }}:{{ cfg.message_queue.password }}@{{ member.host }}:{{ member.get('port', rabbit_port) }}
                             {%- if not loop.last -%},{%- endif -%}
                         {%- endfor -%}
                             /{{ cfg.message_queue.virtual_host }}
{%- else %}
  - transport_url: rabbit://{{ cfg.message_queue.user }}:{{ cfg.message_queue.password }}@{{ cfg.message_queue.host }}:{{ rabbit_port}}/{{ cfg.message_queue.virtual_host }}
{%- endif %}
  - db_engine: {{ cfg.database.engine }}
  - db_password: {{ cfg.database.password }}
  - db_user: {{ cfg.database.user }}
  - db_address: {{ cfg.database.host }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  
{%- endif %}

{%- endif %}
