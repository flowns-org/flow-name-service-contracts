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
  const range = 50
  const times = Math.ceil(len / range)
  // console.log(times)
  let namesArr = []
  let nameMaps = {}
  for (let i = 0; i < times; i++) {
    let names = []
    for (let j = i * range; j < (i + 1) * range; j++) {
      if (records[j]) {
        let name = records[j].name
        name = name.split(',')[0]
        if (nameMaps[name] != true) {
          names.push(name)
          nameMaps[name] = true
        }
      }
    }
    // console.log(names)
    namesArr.push(names)
  }

  // const ress = await Promise.all(namesArr.map(async (names, idx) => {
  //   const res = await buildAndSendTrx('mintDomainBatch', [
  //     fcl.arg(1, t.UInt64),
  //     fcl.arg(names, t.Array(t.String)),
  //     fcl.arg(oneYear.toFixed(2), t.UFix64),
  //   ])
  //   console.log(idx, '====', res)
  // }))
  for (let i = 1; i < namesArr.length; i++) {
    const trxs = await buildAndSendTrx('mintDomainBatch', [
      fcl.arg(1, t.UInt64),
      fcl.arg(namesArr[i], t.Array(t.String)),
      fcl.arg(oneYear.toFixed(2), t.UFix64),
    ])
    await sleep(1000)
    console.log(namesArr[i])
    console.log(namesArr[i].length)
    // console.log(trxs)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
