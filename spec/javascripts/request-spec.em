beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()
  sinon.collection.restore()

describe 'Em.Auth.Request', =>
  follow 'adapter init', 'request'

  example 'request method injection', (method) =>
    it "injects #{method} method to Auth", =>
      expect(@auth[method]).toBeDefined()

    it 'preserves args', =>
      spy = sinon.collection.spy @auth.request, method
      @auth[method]('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

  follow 'request method injection', 'signIn'
  follow 'request method injection', 'signOut'
  follow 'request method injection', 'send'

  example 'request server api', (type) =>
    describe "##{type}", =>
      beforeEach =>
        opts = {}
        opts["#{type}EndPoint"] = '/foo'
        @auth = Em.Auth.create opts

      it 'resolves url', =>
        spy = sinon.collection.spy @auth.request, 'resolveUrl'
        @auth.request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo')

      it 'serializes opts', =>
        spy = sinon.collection.spy @auth.strategy, 'serialize'
        @auth.request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('bar')

      it 'delegates to adapter', =>
        spy = sinon.collection.spy @auth.request.adapter, type
        @auth.request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo', 'bar')

  follow 'request server api', 'signIn'
  follow 'request server api', 'signOut'

  describe '#send', =>
    it 'delegates to adapter', =>
      spy = sinon.collection.spy @auth.request.adapter, 'send'
      @auth.request.send('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

  describe '#resolveUrl', =>

    example 'request resolve url', ({ input, output, isAppend }) =>
      desc = if isAppend then 'appends path to baseUrl' else 'returns path'
      it desc, =>
        expect(@auth.request.resolveUrl(input)).toEqual output
        expect(@auth.request.resolveUrl("/#{input}")).toEqual output

    describe 'baseUrl defined with trialing slash', =>
      beforeEach => @auth = Em.Auth.create { baseUrl: 'foo/' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl defined without trialing slash', =>
      beforeEach => @auth = Em.Auth.create { baseUrl: 'foo' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl = null', =>
      beforeEach => @auth = Em.Auth.create { baseUrl: null }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }

    describe 'baseUrl = empty string', =>
      beforeEach => @auth = Em.Auth.create { baseUrl: '' }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }