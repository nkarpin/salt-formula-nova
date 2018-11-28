linux:
  system:
    enabled: true
    repo:
      mirantis_openstack_repo:
        source: "deb http://mirror.mirantis.com/nightly/openstack-rocky/{{ grains.get('oscodename') }} {{ grains.get('oscodename') }} main"
        architectures: amd64
        key_url: "http://mirror.mirantis.com/nightly/openstack-rocky/{{ grains.get('oscodename') }}/archive-openstack-rocky.key"
        pin:
        - pin: 'release l=rocky'
          priority: 1050
          package: '*'