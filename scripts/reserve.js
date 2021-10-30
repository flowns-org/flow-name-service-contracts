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

const main = async () => {
  fclInit()

  const records = csv.getJsonFromCsv(resolve(__dirname, '../reserve.csv'))
  // console.log(records)
  const len = records.length
  console.log(len)
  let sumNum = 0
  let totalNum = 0
  const range = 50
  const times = Math.ceil(len / range)
  // console.log(times)
  let namesArr = []
  let nameMaps = {}
  for (let i = 0; i < times; i++) {
    console.log(i)
    let names = []
    for (let j = i * range; j < (i + 1) * range; j++) {
      if (records[j]) {
        let name = records[j].name
        name = name.split(',')[0]
        if (nameMaps[name] != true) {
          totalNum += 1
          if (name.indexOf('_') < 0) {
            // console.log(normalize(name), ' ', i * range + j)
          }

          names.push(name)
          nameMaps[name] = true
        } else {
          console.log(name, 'multi')
          sumNum += 1
        }
        // console.log(j)
      }
    }
    // console.log(names)
    namesArr.push(names)
  }
  console.log(sumNum)
  console.log(totalNum)
  // console.log(namesArr.length)
  let currentIdx = 0
  try {
    for (let i = 0; i < namesArr.length; i++) {
      currentIdx = i
      console.log('start mint index', i, '===')
      // const trxs = await buildAndSendTrx('mintDomainBatch', [
      //   fcl.arg(0, t.UInt64),
      //   fcl.arg(namesArr[i], t.Array(t.String)),
      //   fcl.arg(oneYear.toFixed(2), t.UFix64),
      // ])
      // const res = await buildAndExecScript('queryDomainAvailableBatch', [fcl.arg('0x9cadad6f0cd11110b00442613c677688b5928da1c50179f045148363c2e590d3', t.String), fcl.arg(namesArr[i], t.Array(t.String))])
      // await sleep(1000)
      // console.log(namesArr[i])
      // console.log(namesArr[i].length)
      // console.log(trxs ? trxs.status : `error ${i} ${namesArr[i]} `)
      console.log(res)
    }
  } catch (error) {
    console.log(error)
    console.log(currentIdx, '============')
  }

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
