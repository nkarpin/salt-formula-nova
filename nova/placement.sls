{%- from "nova/map.jinja" import cfg,placement with context %}

include:
  - apache
  - nova._common

nova_placement_service_mask:
  file.symlink:
    - name: /etc/systemd/system/nova-placement-api.service
    - target: /dev/null

nova_placement_pkg:
  pkg.installed:
  - names: {{ placement.pkgs }}
  - require:
    - file: nova_placement_service_mask

{#- Creation of sites using templates is deprecated, sites should be generated by apache pillar, and enabled by barbican formula #}
{%- if pillar.get('apache', {}).get('server', {}).get('site', {}).nova_placement is not defined %}

nova_placement_apache_conf_file:
  file.managed:
  - name: /etc/apache2/sites-available/nova-placement-api.conf
  - source: salt://nova/files/{{ cfg.version }}/nova-placement-api.conf
  - template: jinja
  - require:
    - pkg: nova_placement_pkg

placement_config:
  apache_site.enabled:
    - name: nova-placement-api
    - require:
      - nova_placement_apache_conf_file

{%- else %}

nova_cleanup_configs:
  file.absent:
    - names:
      - '/etc/apache2/sites-available/nova-placement-api.conf'
      - '/etc/apache2/sites-enabled/nova-placement-api.conf'

nova_placement_apache_conf_file:
  file.exists:
  - name: /etc/apache2/sites-available/wsgi_nova_placement.conf
  - require:
    - pkg: nova_placement_pkg
    - nova_cleanup_configs

placement_config:
  apache_site.enabled:
    - name: wsgi_nova_placement
    - require:
      - nova_placement_apache_conf_file

{%- endif %}

nova_placement_service:
  service.running:
  - enable: true
  - name: {{ placement.service }}
  {%- if grains.get('noservice') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - sls: nova._ssl.mysql
  - watch:
    - file: /etc/nova/nova.conf
    - file: /etc/nova/api-paste.ini
    - nova_placement_apache_conf_file
    - placement_config
