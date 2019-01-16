{% from "nova/map.jinja" import cfg, controller, compute with context %}

{%- if controller.get('enabled') %}
  {%- set nova_msg = controller.message_queue %}
  {%- set nova_cacert = controller.cacert_file %}
  {%- set role = 'controller' %}
{%- else %}
  {%- if compute.get('enabled') %}
    {%- set nova_msg = compute.message_queue %}
    {%- set nova_cacert = compute.cacert_file %}
    {%- set role = 'compute' %}
  {%- else %}
    {%- set nova_msg = cfg.message_queue %}
    {%- set nova_cacert = cfg.cacert_file %}
    {%- set role = 'common' %}
  {%- endif %}
{%- endif %}

nova_{{ role }}_ssl_rabbitmq:
  test.show_notification:
    - text: "Running nova._ssl.rabbitmq"

{%- if nova_msg.get('x509',{}).get('enabled',False) %}

  {%- set ca_file=nova_msg.x509.ca_file %}
  {%- set key_file=nova_msg.x509.key_file %}
  {%- set cert_file=nova_msg.x509.cert_file %}

rabbitmq_nova_{{ role }}_ssl_x509_ca:
  {%- if nova_msg.x509.cacert is defined %}
  file.managed:
    - name: {{ ca_file }}
    - contents_pillar: nova:{{ role }}:message_queue:x509:cacert
    - mode: 644
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ ca_file }}
  {%- endif %}

rabbitmq_nova_{{ role }}_client_ssl_cert:
  {%- if nova_msg.x509.cert is defined %}
  file.managed:
    - name: {{ cert_file }}
    - contents_pillar: nova:{{ role }}:message_queue:x509:cert
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ cert_file }}
  {%- endif %}

rabbitmq_nova_{{ role }}_client_ssl_private_key:
  {%- if nova_msg.x509.key is defined %}
  file.managed:
    - name: {{ key_file }}
    - contents_pillar: nova:{{ role }}:message_queue:x509:key
    - mode: 640
    - user: root
    - group: nova
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ key_file }}
  {%- endif %}

rabbitmq_nova_{{ role }}_ssl_x509_set_user_and_group:
  file.managed:
    - names:
      - {{ ca_file }}
      - {{ cert_file }}
      - {{ key_file }}
    - user: root
    - group: nova

  {% elif nova_msg.get('ssl',{}).get('enabled',False) %}
rabbitmq_ca_nova_client_{{ role }}:
  {%- if nova_msg.ssl.cacert is defined %}
  file.managed:
    - name: {{ nova_msg.ssl.cacert_file }}
    - contents_pillar: nova:{{ role }}:message_queue:ssl:cacert
    - mode: 644
    - makedirs: true
  {%- else %}
  file.exists:
    - name: {{ nova_msg.ssl.get('cacert_file', nova_cacert) }}
  {%- endif %}

rabbitmq_nova_{{ role }}_ssl_set_user_and_group:
  file.managed:
    - name: {{ nova_msg.ssl.get('cacert_file', nova_cacert) }}
    - user: root
    - group: nova
{%- endif %}
