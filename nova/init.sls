{%- if pillar.nova is defined %}
include:
  {% for i in ['api', 'conductor', 'scheduler', 'placement', 'consoleauth', 'consoleproxy', 'cert_service', 'controller'] %}
    {%- if pillar.nova.get(i) %}
- nova.{{ i }}
    {%- endif %}
  {% endfor %}
  {%- if pillar.nova.compute is defined %}
- nova.compute
  {%- endif %}
  {% if pillar.nova.client is defined %}
- nova.client
  {% endif %}
{% endif %}
