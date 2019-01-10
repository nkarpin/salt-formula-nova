{%- from "nova/map.jinja" import cfg,consoleproxy with context %}

{% if not consoleproxy.get('logging', {}).get('log_appender', False) %}
{%- do consoleproxy.update({'logging': cfg.logging})%}
{% endif %}

{% if not consoleproxy.get('version', {}) %}
{%- do consoleproxy.update({'version': cfg.version})%}
{% endif %}

include:
  - nova._common

{{ consoleproxy.service }}_pkg:
  pkg.installed:
  - names: {{ consoleproxy.pkgs }}

# Only for Queens. Communication between noVNC proxy service and QEMU
{%- if consoleproxy.novncproxy is not defined %}
{%- do consoleproxy.update({'novncproxy': cfg.novncproxy}) %}
{%- endif %}
{%- if consoleproxy.version not in ['mitaka', 'newton', 'ocata', 'pike'] %}
{%- if consoleproxy.novncproxy.vencrypt.tls.get('enabled', False) %}

{%- set ca_file=consoleproxy.novncproxy.vencrypt.tls.get('ca_file') %}
{%- set key_file=consoleproxy.novncproxy.vencrypt.tls.get('key_file') %}
{%- set cert_file=consoleproxy.novncproxy.vencrypt.tls.get('cert_file') %}

novncproxy_vencrypt_ca:
{%- if consoleproxy.novncproxy.vencrypt.tls.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: nova:consoleproxy:novncproxy:vencrypt:tls:cacert
    - mode: 644
    - makedirs: true
    - user: root
    - group: nova
    - watch_in:
      - service: nova_consoleproxy_service
{%- else %}
  file.exists:
   - name: {{ ca_file }}
{%- endif %}

novncproxy_vencrypt_public_cert:
{%- if consoleproxy.novncproxy.vencrypt.tls.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: nova:consoleproxy:novncproxy:vencrypt:tls:cert
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ cert_file }}
{%- endif %}

novncproxy_vencrypt_private_key:
{%- if consoleproxy.novncproxy.vencrypt.tls.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: nova:consoleproxy:novncproxy:vencrypt:tls:key
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ key_file }}
{%- endif %}

novncproxy_vencrypt_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: root
    - group: nova

{%- endif %}
{%- endif %}

{%- if consoleproxy.novncproxy.tls.get('enabled', False) %}
{%- set key_file=consoleproxy.novncproxy.tls.server.get('key_file') %}
{%- set cert_file=consoleproxy.novncproxy.tls.server.get('cert_file') %}

novncproxy_server_public_cert:
{%- if consoleproxy.novncproxy.tls.server.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: nova:consoleproxy:novncproxy:tls:server:cert
    - mode: 644
    - makedirs: true
    - user: root
    - group: nova
    - watch_in:
      - service: nova_consoleproxy_service
{%- else %}
  file.exists:
   - name: {{ cert_file }}
{%- endif %}

novncproxy_server_private_key:
{%- if consoleproxy.novncproxy.tls.server.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: nova:consoleproxy:novncproxy:tls:server:key
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
{%- else %}
  file.exists:
   - name: {{ key_file }}
{%- endif %}

novncproxy_server_set_user_and_group:
  file.managed:
    - names:
      - {{ cert_file }}
      - {{ key_file }}
    - user: root
    - group: nova

{%- endif %}

{{ consoleproxy.service }}:
  service.running:
  - enable: true
  {%- if grains.get('noservice') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova._ssl.mysql
    - sls: nova._ssl.rabbitmq
    - pkg: {{ consoleproxy.service }}_pkg
  - watch:
    - file: /etc/nova/nova.conf
{% if consoleproxy.get('logging', {}).get('log_appender', False) %}
    - file: nova_general_logging_conf
{% endif %}

{% if consoleproxy.logging.log_appender == True %}
{%- set service_name = consoleproxy.service %}
{%- set config = consoleproxy %}
{%- include "nova/_logging.sls" %}
{% endif %}
