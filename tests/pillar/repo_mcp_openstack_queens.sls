linux:
  system:
    enabled: true
    repo:
      mirantis_openstack_repo:
        source: "deb http://mirror.mirantis.com/nightly/openstack-queens/{{ grains.get('oscodename') }} {{ grains.get('oscodename') }} main"
        architectures: amd64
        key_url: "http://mirror.mirantis.com/nightly/openstack-queens/{{ grains.get('oscodename') }}/archive-queens.key"
        pin:
        - pin: 'release l=queens'
          priority: 1050
          package: '*'