{%- from "nova/map.jinja" import cfg,consoleauth with context %}

{% if not consoleauth.get('logging', {}).get('log_appender', False) %}
{%- do consoleauth.update({'logging': cfg.logging})%}
{% endif %}

include:
  - nova._common

{{ consoleauth.service }}_pkg:
  pkg.installed:
  - names: {{ consoleauth.pkgs }}

{{ consoleauth.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ consoleauth.service }}_pkg
  - watch:
    - file: /etc/nova/nova.conf
{% if consoleauth.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{% endif %}

{% if consoleauth.logging.log_appender == True %}
{%- set service_name = consoleauth.service %}
{%- set config = consoleauth %}
{%- include "nova/_logging.sls" %}
{% endif %}
