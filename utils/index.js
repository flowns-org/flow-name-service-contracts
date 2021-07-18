import fs from 'fs'
import { authz } from './authz.js'
import fcl from '@onflow/fcl'
import { nodeUrl, accountAddr } from '../config/constants.js'
import { dirname, resolve } from 'path'
import { fileURLToPath } from 'url'
const __dirname = dirname(fileURLToPath(import.meta.url))

export const fclInit = () => {
  fcl
    .config()
    .put('accessNode.api', nodeUrl)
    .put('0xDomains', accountAddr)
    .put('0xFlowns', accountAddr)
    .put('0xNonFungibleToken', accountAddr)
}

export const sendTrx = async (CODE, args) => {
  const txId = await fcl
    .send([
      fcl.transaction(CODE),
      fcl.args(args),
      fcl.proposer(authz),
      fcl.payer(authz),
      fcl.authorizations([authz]),
      fcl.limit(200),
    ])
    .then(fcl.decode)

  return txId
}

export const readCode = async (path) => {
  const data = fs.readFileSync(resolve(__dirname, path), 'utf-8')
  return data
}

export default {}
