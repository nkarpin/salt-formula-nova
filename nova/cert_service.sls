{%- from "nova/map.jinja" import cfg,cert_service with context %}

{% if not cert_service.get('logging', {}).get('log_appender', False) %}
{%- do cert_service.update({'logging': cfg.logging})%}
{% endif %}

include:
  - nova._common

{{ cert_service.service }}_pkg:
  pkg.installed:
  - names: {{ cert_service.pkgs }}

{{ cert_service.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova.db.offline_sync
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ cert_service.service }}_pkg
  - require_in:
    - sls: nova.db.online_sync
  - watch:
    - file: /etc/nova/nova.conf
{% if cert_service.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{% endif %}

{% if cert_service.logging.log_appender == True %}
{%- set service_name = cert_service.service %}
{%- set config = cert_service %}
{%- include "nova/_logging.sls" %}
{% endif %}
