base:
  '*':
    - consul.init
    {% if salt['grains.equals'] ('virtual', 'VirtualBox') %}
    - vault.init
    {% endif %}
  'server-0.c.rebirthdb-infra.internal':
    - vault.init