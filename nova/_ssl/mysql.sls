{% from "nova/map.jinja" import cfg,controller with context %}

nova_ssl_mysql:
  test.show_notification:
    - text: "Running nova._ssl.mysql"

{%- if controller.get('enabled') %}
  {%- set role = 'controller' %}
{%- else %}
  {%- set role = 'common' %}
{%- endif %}

{%- if cfg.database.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=cfg.database.x509.ca_file %}
  {%- set key_file=cfg.database.x509.key_file %}
  {%- set cert_file=cfg.database.x509.cert_file %}

mysql_nova_ssl_x509_ca:
  {%- if cfg.database.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: nova:{{ role }}:database:x509:cacert
    - mode: 644
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

mysql_nova_client_ssl_cert:
  {%- if cfg.database.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: nova:{{ role }}:database:x509:cert
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

mysql_nova_client_ssl_private_key:
  {%- if cfg.database.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: nova:{{ role }}:database:x509:key
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

mysql_nova_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: root
    - group: nova

  {% elif cfg.database.get('ssl',{}).get('enabled',False) %}
mysql_ca_nova_{{ role }}:
  {%- if cfg.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ cfg.database.ssl.cacert_file }}
    - contents_pillar: nova:{{ role }}:database:ssl:cacert
    - mode: 644
    - makedirs: true
    - user: root
    - group: nova
  {%- else %}
  file.exists:
    - name: {{ cfg.database.ssl.get('cacert_file', cfg.cacert_file) }}
  {%- endif %}

mysql_nova_ssl_set_user_and_group:
  file.managed:
    - name: {{ cfg.database.ssl.get('cacert_file', cfg.cacert_file) }}
    - user: root
    - group: nova

{%- endif %}
