module.exports =
  'url': '/api/v1',
  'method-override':
    methods: [ 'POST' ],
    getters: [
      '_method',
      'X-HTTP-Method',
      'X-Method-Override',
      'X-HTTP-Method-Override'
    ]
  'database':
    'adapter': 'redis'
    'options':
      'port': 0
      'host': 'localhost'
