import { dirname, resolve } from 'path'
import { fileURLToPath } from 'url'

import csv from 'convert-csv-to-json'
import t from '@onflow/types'
import fcl from '@onflow/fcl'
import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import { sleep } from '../utils/index.js'

import { accountAddr } from '../config/constants.js'
import { test1Addr, test2Addr, test1Authz } from '../utils/authz.js'
import { namehash, normalize } from '../utils/hash.js'
const __dirname = dirname(fileURLToPath(import.meta.url))
const oneYear = 60 * 60 * 24 * 365
const regCap = /[A-Z].*/

const validateName = (name) => {
  const chars = '!@#$%^&*()<>? ./_ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  let names = Array.from(name)
  const flag = names.find((c) => {
    return chars.indexOf(c) >= 0
  })
  if (flag !== undefined) {
    console.log(flag, name, '========')
    return true
  }
  return false
}

const main = async () => {
  fclInit()

  const records = csv.getJsonFromCsv(resolve(__dirname, '../final.csv'))
  // console.log(records)
  const len = records.length
  console.log(len)
  let ids = []
  let sumNum = 0
  let totalNum = 0
  const range = 50
  const times = Math.ceil(len / range)
  // console.log(times)
  let namesArr = []
  let idArr = []
  let nameMaps = {}
  const tempArr = []

  for (let i = 0; i < times; i++) {
    // console.log(i)
    let names = []
    let idds = []
    for (let j = i * range; j < (i + 1) * range; j++) {
      if (records[j]) {
        let obj = records[j]['id,name,uuid']
        // name = name.split(',')[0]
        const datas = obj.split(',')
        const name = datas[1]
        const uuid = datas[2]
        // const id = datas[0]

        // if (idrange.indexOf(Number(id)) >= 0) {
        //   console.log(id, '====')
        //   tempArr.push(name)
        // }
        if (nameMaps[name] != true) {
          totalNum += 1
          if (name.indexOf('_') >= 0) {
            // ids.push(uuid)
          } else if (regCap.test(name)) {
            console.log(name, '====')
            // ids.push(uuid)
          } else if (validateName(name)) {
            console.log(name, '====')
            // ids.push(uuid)
          } else {
            // names.push(name)
            names.push(namehash(`${name}.fn`))
            idds.push(uuid)
            nameMaps[name] = true
          }
        } else {
          console.log(name, 'multi')
          sumNum += 1
        }
        // console.log(j)
      }
    }
    // console.log(names)
    namesArr.push(names)
    idArr.push(idds)
  }
  // console.log(sumNum)
  // console.log(totalNum)
  // console.log(namesArr.length)
  let currentIdx = 0

  // const firsR = await buildAndExecScript('queryDomainAvailableBatch', [
  //   fcl.arg('0x9cadad6f0cd11110b00442613c677688b5928da1c50179f045148363c2e590d3', t.String),
  //   fcl.arg(tempArr, t.Array(t.String)),
  // ])
  // console.log(firsR)

  try {
    for (let i = 0; i < namesArr.length; i++) {
      currentIdx = i
      console.log('start mint index', i, '===')
      // const trxs = await buildAndSendTrx('mintDomainBatch', [
      //   fcl.arg(0, t.UInt64),
      //   fcl.arg(namesArr[i], t.Array(t.String)),
      //   fcl.arg(oneYear.toFixed(2), t.UFix64),
      // ])
      let res = await buildAndExecScript('queryDomainAvailableBatch', [
        fcl.arg(namesArr[i], t.Array(t.String)),
      ])
      await sleep(1000)
      // console.log(namesArr[i])
      // console.log(namesArr[i].length)
      // console.log(trxs ? trxs.status : `error ${i} ${namesArr[i]} `)
      res = res.map((flag, idx) => {
        if (flag === true) {
          ids.push(idArr[i][idx])
        }
        return `${flag} ${idArr[i][idx]}`
      })
      console.log(res)
    }
  } catch (error) {
    console.log(error)
    // console.log(currentIdx, '============')
  }
  console.log(ids.length)
  console.log(`(${ids})`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
