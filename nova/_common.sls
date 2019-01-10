{%- from "nova/map.jinja" import cfg with context %}

include:
  - nova._ssl.mysql
  - nova._ssl.rabbitmq

nova_common_packages:
  pkg.installed:
    - names: ['nova-common', 'python-memcache', 'gettext-base', 'python-novaclient', 'python-pycadf', 'nova-doc']
    - install_recommends: False
    - require_in:
      - sls: nova._ssl.mysql
      - sls: nova._ssl.rabbitmq

{%- if not salt['user.info']('nova') %}
user_nova:
  user.present:
  - name: nova
  - home: /var/lib/nova
  - shell: /bin/false
  {# note: nova uid/gid values would not be evaluated after user is created. #}
  - uid: {{ cfg.get('nova_uid', 303) }}
  - gid: {{ cfg.get('nova_gid', 303) }}
  - system: True
  - require_in:
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: nova_common_packages

group_nova:
  group.present:
    - name: nova
    {# note: nova gid value would not be evaluated after user is created. #}
    - gid: {{ cfg.get('nova_gid', 303) }}
    - system: True
    - require_in:
      - user: user_nova
{%- endif %}

/etc/nova/nova.conf:
  file.managed:
  - source: salt://nova/files/{{ cfg.version }}/nova-controller.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: nova_common_packages
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
  - require_in:
    - sls: nova.db.offline_sync
    - sls: nova.db.api_sync
    - sls: nova.db.online_sync

/etc/nova/api-paste.ini:
  file.managed:
  - source: salt://nova/files/{{ cfg.version }}/api-paste.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: nova_common_packages

{%- if cfg.logging.log_appender %}

{%- if cfg.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
nova_common_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

nova_general_logging_conf:
  file.managed:
    - name: /etc/nova/logging.conf
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - user: nova
    - group: nova
    - require_in:
      - sls: nova.db.offline_sync
      - sls: nova.db.api_sync
    - require:
      - pkg: nova_common_packages
  {%- if cfg.logging.log_handlers.get('fluentd').get('enabled', False) %}
      - pkg: nova_common_fluentd_logger_package
  {%- endif %}
    - defaults:
        service_name: nova
        _data: {{ cfg.logging }}
{%- endif %}

{%- if grains.get('virtual_subtype', None) == "Docker" %}

nova_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://nova/files/entrypoint.sh
  - mode: 755

{%- endif %}
