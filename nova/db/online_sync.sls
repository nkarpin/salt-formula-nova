{% from "nova/map.jinja" import cfg with context %}

{%- set should_run = '/bin/false' %}
{%- if not grains.get('noservices') and cfg.version not in ["juno", "kilo", "liberty"] and cfg.get('role', 'primary') == 'primary' %}
{%- set should_run = '/bin/true' %}
{%- endif %}

nova_controller_online_data_migrations:
  cmd.run:
  - name: nova-manage db online_data_migrations
  - onlyif: {{ should_run }}
  - runas: 'nova'
