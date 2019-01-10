{{ service_name }}_logging_conf:
  file.managed:
    - name: /etc/nova/logging/logging-{{ service_name }}.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - makedirs: True
    - user: nova
    - group: nova
    - defaults:
        service_name: {{ service_name }}
        _data: {{ config.logging }}
    - require:
      - pkg: {{ service_name }}_pkg
{%- if config.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: nova_common_fluentd_logger_package
{%- endif %}
    - watch_in:
      - service: {{ service_name }}

{{ service_name }}_default:
  file.managed:
    - name: /etc/default/{{ service_name }}
    - source: salt://nova/files/default
    - template: jinja
    - require:
      - pkg: {{ service_name }}_pkg
    - defaults:
        service_name: {{ service_name }}
        values: {{ config }}
    - watch_in:
      - service: {{ service_name }}