nova:
  controller:
    enabled: true
    networking: contrail
    version: queens
    security_group: false
    vncproxy_url: 127.0.0.1
    vnc_keymap: en-gb
    dhcp_domain: novalocal
    scheduler_default_filters:
      - DifferentHostFilter
      - RetryFilter
      - AvailabilityZoneFilter
      - RamFilter
      - CoreFilter
      - DiskFilter
      - ComputeFilter
      - ComputeCapabilitiesFilter
      - ImagePropertiesFilter
      - ServerGroupAntiAffinityFilter
      - ServerGroupAffinityFilter
    cpu_allocation_ratio: 16.0
    ram_allocation_ratio: 1.5
    disk_allocation_ratio: 1.0
    workers: 8
    nfs_mount_options: 'vers=3,lookupcache=pos'
    bind:
      private_address: 127.0.0.1
      public_address: 127.0.0.1
      public_name: 127.0.0.1
      novncproxy_port: 6080
    database:
      engine: mysql
      host: localhost
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
      log_appender: false
      log_handlers:
        watchedfile:
          enabled: true
        fluentd:
          enabled: false
        ossyslog:
          enabled: false
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
    glance:
      host: 127.0.0.1
      port: 9292
    network:
      engine: neutron
      region: RegionOne
      host: 127.0.0.1
      port: 9696
      mtu: 1500
      password: password
    metadata:
      password: password
    cache:
      engine: memcached
      members:
      - host: 127.0.0.1
        port: 11211
      security:
        enabled: true
        strategy: ENCRYPT
        secret_key: secret
    consoleauth:
      token_ttl: 600
    policy:
      'context_is_admin': 'role:admin or role:administrator'
      'compute:create': 'rule:admin_or_owner'
      'compute:create:attach_network':
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
