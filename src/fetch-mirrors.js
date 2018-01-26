'use strict';

var _bluebird = require('bluebird');

const Promise = require('bluebird');
Promise.config({ longStackTraces: true, warnings: true });
const cheerio = require('cheerio');
const needle = require('needle');
const debug = require('debug')('mh:docker:kind:mirrors');
const fs = Promise.promisifyAll(require('fs'));
const readline = require('readline');
const path = require('path');

class Fetch {

  static fetchAndCheerio(url) {
    return (0, _bluebird.coroutine)(function* () {
      debug('retriving url: %s', url);
      let response = yield needle('get', url);
      debug('retrieved response:', response.body);
      return cheerio.load(response.body);
    })();
  }

  static /*async*/fetchCentos() {
    return new Promise((resolve, reject) => {
      let response = needle.get('https://www.centos.org/download/full-mirrorlist.csv');
      const line_reader = require('readline').createInterface({
        input: response
      });

      const mirrors = [];

      line_reader.on('line', line => {
        // poor mans csv parsing, remove leading and trailing `"`s
        // then splut the string on `","`. 
        // Only works when every field is quoted with `"`
        line.replace(/^"/, '').replace(/"$/, '');
        let fields = line.split(/","/);
        if (fields.length > 4 && fields[4]) {
          //debug('fields', fields)
          mirrors.push(fields[4]);
        } else {
          if (fields.length === 1 || fields[5] && fields[5].includes('ftp')) return;
          console.error('centos - bad line', line);
        }
      });

      line_reader.on('close', () => {
        debug('centos mirrors', mirrors.join("\n"));
        resolve(mirrors);
      });

      line_reader.on('error', () => reject(error));
    });
  }

  static fetchEpel() {
    var _this = this;

    return (0, _bluebird.coroutine)(function* () {
      let $ = yield _this.fetchAndCheerio('https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL');
      let $rows = $('.container table').first().find('tr');
      let mirrors = [];
      $rows.each(function (row, el) {
        let mirror_info = $(el).children('td').slice(3, 4).contents();
        let mode = null;
        mirror_info.each(function (mirror_data, el) {
          if (el.type === 'text') {
            if (/Fedora EPEL/.exec(el.data)) mode = 'epel';
            if (/Fedora Linux/.exec(el.data)) mode = 'fedora';
          }
          if (mode === 'epel' && el.type === 'tag' && el.name === 'a' && $(el).text() === 'http') {
            mirrors.push($(el).attr('href'));
          }
        });
      });
      debug('epel mirrors', mirrors.join('\n'));
      return mirrors;
    })();
  }

  static fetchFedora() {
    var _this2 = this;

    return (0, _bluebird.coroutine)(function* () {
      let $ = yield _this2.fetchAndCheerio('https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora');
      let $rows = $('.container table').first().find('tr');
      let mirrors = [];
      /*
      $rows.map((row,el) => {
        return $(el).children('td').slice(3,4).find('a').each((linki, el)=> {
          if ( $(el).text() === 'http' ) mirrors.push($(el).attr('href'))
        })
      })
      */
      $rows.each(function (row, el) {
        let mirror_info = $(el).children('td').slice(3, 4).contents();
        let mode = null;
        mirror_info.each(function (mirror_data, el) {
          if (el.type === 'text') {
            if (/Fedora EPEL/.exec(el.data)) mode = 'epel';
            if (/Fedora Linux/.exec(el.data)) mode = 'fedora';
          }
          if (mode === 'fedora' && el.type === 'tag' && el.name === 'a' && $(el).text() === 'http') {
            mirrors.push($(el).attr('href'));
          }
        });
      });
      debug('fedora mirrors', mirrors.join('\n'));
      return mirrors;
    })();
  }

  static fetchApache() {
    var _this3 = this;

    return (0, _bluebird.coroutine)(function* () {
      let $ = yield _this3.fetchAndCheerio('https://www.apache.org/mirrors/dist.html');
      let $rows = $('table tr');
      let mirrors = [];
      $rows.each(function (rowi, el) {
        let $el = $(el);
        let cols = $el.find('td');
        debug('apache row %s: size %s: ', rowi, cols.length, $(cols).text());
        if (cols.length === 5) {
          let $mirror_col = $($(cols).get(0));
          let $scheme_col = $($(cols).get(1));
          let is_http = $scheme_col.text().includes('http');
          let mirror_link = $mirror_col.find('a').first().attr('href');
          debug('is_https: %s  mirror: %s', is_http, mirror_link);
          if (is_http === true) mirrors.push(mirror_link);
        }
      });
      return mirrors;
    })();
  }

  static writeMirror(file, promise) {
    return (0, _bluebird.coroutine)(function* () {
      let file_path = path.resolve(__dirname, '..', 'files', file);
      if (typeof promise === 'function') promise = promise();
      let mirror_data = yield promise;
      debug('writeMirror has got the mirror data for file "%s"', file);
      return fs.writeFileAsync(file_path, mirror_data.join('\n'));
    })();
  }

  static go() {
    var _this4 = this;

    return (0, _bluebird.coroutine)(function* () {
      try {
        yield _this4.writeMirror('centos_mirrors', function () {
          return _this4.fetchCentos();
        });
        yield _this4.writeMirror('fedora_mirrors', function () {
          return _this4.fetchFedora();
        });
        yield _this4.writeMirror('epel_mirrors', function () {
          return _this4.fetchEpel();
        });
        yield _this4.writeMirror('apache_mirrors', function () {
          return _this4.fetchApache();
        });
      } catch (error) {
        console.log(error);
      }
    })();
  }
}

Fetch.go();

