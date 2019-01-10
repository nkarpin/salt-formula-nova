{%- if pillar.nova is defined %}
include:
  {%- if pillar.nova.api is defined %}
- nova.api
  {%- endif %}
  {%- if pillar.nova.placement is defined %}
- nova.placement
  {%- endif %}
  {%- if pillar.nova.scheduler is defined %}
- nova.scheduler
  {%- endif %}
  {%- if pillar.nova.conductor is defined %}
- nova.conductor
  {%- endif %}
  {%- if pillar.nova.consoleproxy is defined %}
- nova.consoleproxy
  {%- endif %}
  {%- if pillar.nova.cert_service is defined %}
- nova.cert_service
  {%- endif %}
  {%- if pillar.nova.controller is defined %}
- nova.controller
  {%- endif %}
  {%- if pillar.nova.compute is defined %}
- nova.compute
  {%- endif %}
  {% if pillar.nova.client is defined %}
- nova.client
  {% endif %}
{% endif %}
