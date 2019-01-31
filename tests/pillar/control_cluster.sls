nova:
  controller:
    enabled: true
    networking: default
    version: pike
    vncproxy_url: 127.0.0.1
    vnc_keymap: en-gb
    security_group: false
    dhcp_domain: novalocal
    scheduler_default_filters: "DifferentHostFilter,RetryFilter,AvailabilityZoneFilter,RamFilter,CoreFilter,DiskFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter"
    cpu_allocation_ratio: 16.0
    ram_allocation_ratio: 1.5
    disk_allocation_ratio: 1.0
    workers: 8
    bind:
      private_address: 127.0.0.1
      public_address: 127.0.0.1
      public_name: 127.0.0.1
      novncproxy_port: 6080
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: nova
      user: nova
      password: password
      idle_timeout: 180
      min_pool_size: 100
      max_pool_size: 700
      max_overflow: 100
      retry_interval: 5
      max_retries: '-1'
      db_max_retries: 3
      db_retry_interval: 1
      connection_debug: 10
      pool_timeout: 120
    identity:
      engine: keystone
      region: RegionOne
      host: 127.0.0.1
      port: 35357
      user: nova
      password: password
      tenant: service
    logging:
      log_appender: true
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: true
        ossyslog:
          enabled: true
    message_queue:
      engine: rabbitmq
      members:
      - host: 127.0.0.1
      - host: 127.0.1.1
      - host: 127.0.2.1
      user: openstack
      password: password
      virtual_host: '/openstack'
    glance:
      host:
      port: 9292
    network:
      engine: neutron
      region: RegionOne
      host: 127.0.0.1
      port: 9696
      mtu: 1500
      user: nova
      password: password
      tenant: service
    metadata:
      password: metadata
    audit:
      filter_factory: 'keystonemiddleware.audit:filter_factory'
      map_file: '/etc/pycadf/nova_api_audit_map.conf'
    policy:
      'context_is_admin': 'role:admin or role:administrator'
      'compute:create': 'rule:admin_or_owner'
      'compute:create:attach_network':
    upgrade_levels:
      compute: liberty
    barbican:
      enabled: true
    consoleauth:
      token_ttl: 600
    reclaim_instance_interval: 60
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      nova_placement:
        enabled: false
        available: true
        type: wsgi
        name: nova_placement
        wsgi:
          daemon_process: nova-placement
          processes: 5
          threads: 1
          user: nova
          group: nova
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/nova-placement-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        limits:
          request_body: 114688
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 8778
