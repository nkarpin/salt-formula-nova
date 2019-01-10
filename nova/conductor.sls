{%- from "nova/map.jinja" import cfg,conductor with context %}

{% if not conductor.get('logging', {}).get('log_appender', False) %}
{%- do conductor.update({'logging': cfg.logging})%}
{% endif %}

include:
  - nova._common

{{ conductor.service }}_pkg:
  pkg.installed:
  - names: {{ conductor.pkgs }}

{{ conductor.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova.db.offline_sync
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ conductor.service }}_pkg
  - require_in:
    - sls: nova.db.online_sync
  - watch:
    - file: /etc/nova/nova.conf
{% if conductor.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{% endif %}

{% if conductor.logging.log_appender == True %}
{%- set service_name = conductor.service %}
{%- set config = conductor %}
{%- include "nova/_logging.sls" %}
{% endif %}
