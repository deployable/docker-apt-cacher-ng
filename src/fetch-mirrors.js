const Promise = require('bluebird')
const cheerio = require('cheerio')
const needle = require('needle')
const debug = require('debug')('mh:docker:kind:mirrors')
const fs = Promise.promisifyAll(require('fs'))
const readline = require('readline')
const path = require('path')

async function goNet(){
  let response = await needle('get', 'https://www.centos.org/download/mirrors/')
  let $ = cheerio.load(response.body)
  debug(response.body)
  let mirrors = $('table.CSVTable tr').map((row,el) => $(el).children('td').slice(3,4).text()).get()
  console.log(mirrors.join('\n'))
}

async function fetchCentos(){
  return new Promise((resolve,reject) => {
    let response = needle.get('https://www.centos.org/download/full-mirrorlist.csv')
    const line_reader = require('readline').createInterface({
      input: response
    })

    const mirrors = []

    line_reader.on('line', line => {
      line.replace(/^"/,'').replace(/"$/,'')
      let fields = line.split(/","/)
      if ( fields.length > 4 && fields[4] ) {
        //debug('fields', fields)
        mirrors.push(fields[4])
      } 
      else {
        console.error('bad line', line)
      }
    })

    line_reader.on('close', ()=>{
      debug('centos mirrors', mirrors.join("\n"))
      resolve(mirrors)
    })

    line_reader.on('error', ()=> reject(error))
  })
}

async function fetchEpel(){
  let response = await needle('get', 'https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL')
  let $ = cheerio.load(response.body)
  let $rows = $('.container table').first().find('tr')
  let mirrors = []
  $rows.each((row,el) => {
    let mirror_info = $(el).children('td').slice(3,4).contents()
    let mode = null
    mirror_info.each((mirror_data, el) => {
      if ( el.type === 'text' ) {
        if ( /Fedora EPEL/.exec(el.data) ) mode = 'epel'
        if ( /Fedora Linux/.exec(el.data) ) mode = 'fedora'
      }
      if ( mode === 'epel' && el.type === 'tag' && el.name === 'a' && $(el).text() === 'http' ) {
        mirrors.push($(el).attr('href'))
      }
    })
  })
  debug('epel mirrors', mirrors.join('\n'))
  return mirrors 
}

async function fetchFedora(){
  let response = await needle('get', 'https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora')
  let $ = cheerio.load(response.body)
  let $rows = $('.container table').first().find('tr')
  let mirrors = []
  /*
  $rows.map((row,el) => {
    return $(el).children('td').slice(3,4).find('a').each((linki, el)=> {
      if ( $(el).text() === 'http' ) mirrors.push($(el).attr('href'))
    })
  })
  */
  $rows.each((row,el) => {
    let mirror_info = $(el).children('td').slice(3,4).contents()
    let mode = null
    mirror_info.each((mirror_data, el) => {
      if ( el.type === 'text' ) {
        if ( /Fedora EPEL/.exec(el.data) ) mode = 'epel'
        if ( /Fedora Linux/.exec(el.data) ) mode = 'fedora'
      } 
      if ( mode === 'fedora' && el.type === 'tag' && el.name === 'a' && $(el).text() === 'http' ) {
        mirrors.push($(el).attr('href'))  
      }
    })
  })
  debug('fedora mirrors', mirrors.join('\n'))
  return mirrors 
}

async function writeMirror( file, pmData ){
  let file_path = path.resolve( __dirname, '..', 'files', file )
  let mirror_data = await pmData
  return fs.writeFileAsync(file_path, mirror_data.join('\n'))
}

async function go(){
  try {
    writeMirror('centos_mirrors', fetchCentos())
    writeMirror('fedora_mirrors', fetchFedora())
    writeMirror('epel_mirrors', fetchEpel())
  }
  catch (error) {
    console.log(error)
  }

}

go()
