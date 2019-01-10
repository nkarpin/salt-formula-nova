{%- from "nova/map.jinja" import cfg,scheduler with context %}

{% if not scheduler.get('logging', {}).get('log_appender', False) %}
{%- do scheduler.update({'logging': cfg.logging})%}
{% endif %}

include:
  - nova._common

{{ scheduler.service }}_pkg:
  pkg.installed:
  - names: {{ scheduler.pkgs }}

{{ scheduler.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ scheduler.service }}_pkg
  - watch:
    - file: /etc/nova/nova.conf
{% if scheduler.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{% endif %}

{% if scheduler.logging.log_appender == True %}
{%- set service_name = scheduler.service %}
{%- set config = scheduler %}
{%- include "nova/_logging.sls" %}
{% endif %}
