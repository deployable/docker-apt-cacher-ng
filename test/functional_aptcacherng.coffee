Promise = require('bluebird')
needle = Promise.promisifyAll(require('needle'))
cheerio = require('cheerio')
debug = require('debug') 'dply:test:func:aptcacherng'

request_options =
  proxy: 'http://127.0.0.1:3142'

getCacherPage = ( repo_url )->
  needle.getAsync repo_url, request_options


describe 'cache requests', ->

  it 'responds with an apt error for a directory', ->
    getCacherPage 'http://dl-cdn.alpinelinux.org/alpine/v3.5/', request_options
      .then (res) ->
        expect( res ).to.be.ok
        $ = cheerio.load(res.body)
        expect( $('body').text() ).to.match /Apt-Cacher NG/

# curl 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main/x86_64/APKINDEX.tar.gz' -H 'Host: dl-cdn.alpinelinux.org' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:45.0) Gecko/20100101 Firefox/45.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: http://dl-cdn.alpinelinux.org/alpine/v3.5/main/x86_64/' -H 'Connection: keep-alive'

  describe 'pulling a file', ->

    file_request_options = request_options
    res = null
    
    before ->
      @timeout(5000)
      getCacherPage 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main/x86_64/APKINDEX.tar.gz', file_request_options
        .then (result) ->
           debug(result)
           res = result
 
    it 'sould return a response', ->
      expect( res ).to.be.ok

    it 'sould return a buffer for the body', ->
      expect( res.body ).to.be.an.instanceof Buffer

    it 'should have headers', ->
      expect( res.headers ).to.be.ok

    it 'should have a bzip content type', ->
      expect( res.headers['content-type'] ).to.equal 'application/octet-stream'
 
    it 'should have a statusCode of 200', ->
      expect( res.statusCode ).to.equal 200

