module.exports =
  'endpoint': '/api/v1'
  'scopes': [ 'admin', 'user' ]
  'method-override':
    'methods': [ 'POST' ],
    'getters': [
      '_method',
      'X-HTTP-Method',
      'X-Method-Override',
      'X-HTTP-Method-Override'
    ]
  'database':
    'default':
      'driver': 'redis'
      'options':
        'port': 0
        'host': 'localhost'
  'authorization':
    'secret': 'secret'
    'requestProperty': 'auth'
  'resource':
    'scopes': [ 'user' ],
    'methods': [ 'get', 'put', 'post', 'delete' ],
    'routes': [
      { 'path': '/' },
      { 'path': '/:id' }
    ]
  'errors':
    'UnauthorizedError':
      'status': 401
      'message': 'Invalid Token'
