{%- from "nova/map.jinja" import cfg,api with context %}

{% if not api.get('logging', {}).get('log_appender', False) %}
{%- do api.update({'logging': cfg.logging})%}
{% endif %}

include:
- nova._common
- nova.db.api_sync
# TODO(vsaienko) we need to run online dbsync only once after upgrade
# Move to appropriate upgrade phase
- nova.db.online_sync

{{ api.service }}_pkg:
  pkg.installed:
  - names: {{ api.pkgs }}

{% if api.get('policy', {}) and api.version not in ['liberty', 'mitaka', 'newton'] %}
{# nova no longer ships with a default policy.json #}

/etc/nova/policy.json:
  file.managed:
    - contents: '{}'
    - replace: False
    - user: nova
    - group: nova
    - require:
      - pkg: nova_common_packages

{% endif %}

{%- for name, rule in api.get('policy', {}).iteritems() %}

  {%- if rule != None %}
nova_keystone_rule_{{ name }}_present:
  keystone_policy.rule_present:
  - path: /etc/nova/policy.json
  - name: {{ name }}
  - rule: {{ rule }}
  - require:
    - pkg: nova_common_packages
    {% if api.version not in ['liberty', 'mitaka', 'newton'] %}
    - file: /etc/nova/policy.json
    {% endif%}

  {%- else %}

nova_keystone_rule_{{ name }}_absent:
  keystone_policy.rule_absent:
  - path: /etc/nova/policy.json
  - name: {{ name }}
  - require:
    - pkg: nova_common_packages
    {% if api.version not in ['liberty', 'mitaka', 'newton'] %}
    - file: /etc/nova/policy.json
    {% endif%}

  {%- endif %}

{%- endfor %}

{{ api.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova.db.api_sync
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ api.service }}_pkg
  - require_in:
    - sls: nova.db.online_sync
  - watch:
    - file: /etc/nova/nova.conf
    - file: /etc/nova/api-paste.ini
{% if api.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{%- endif %}

{% if api.logging.log_appender == True %}
{%- set service_name = api.service %}
{%- set config = api %}
{%- include "nova/_logging.sls" %}
{% endif %}
