module.exports =
  'endpoint': '/api/v1'
  'method-override':
    'methods': [ 'POST' ],
    'getters': [
      '_method',
      'X-HTTP-Method',
      'X-Method-Override',
      'X-HTTP-Method-Override'
    ]
  'database':
    'api':
      'driver': 'mongoose'
      'options':
        'host': 'localhost'
        'port': '27017'
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
    'InvalidResourceError':
      'status': 400
      'message': 'Invalid Resource'
