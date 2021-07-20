import fs from 'fs'
import { authz } from './authz.js'
import fcl from '@onflow/fcl'
import { nodeUrl, accountAddr, paths, flowTokenAddr, flowFungibleAddr } from '../config/constants.js'
import { dirname, resolve } from 'path'
import { fileURLToPath } from 'url'
const __dirname = dirname(fileURLToPath(import.meta.url))
const { setup, scripts, transactions } = paths

export const fclInit = () => {
  fcl
    .config()
    .put('accessNode.api', nodeUrl)
    .put('0xDomains', accountAddr)
    .put('0xFlowns', accountAddr)
    .put('0xNonFungibleToken', accountAddr)
    .put('0xFungibleToken', flowFungibleAddr)
    .put('0xFlowToken', flowTokenAddr)
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

export const execScript = async (script, args = []) => {
  return await fcl.send([fcl.script`${script}`, fcl.args(args)]).then(fcl.decode)
}

export const buildAndSendTrx = async (key, args = []) => {
  const trxScript = await readCode(transactions[key])
  const trxId = await sendTrx(trxScript, args)
  console.log(trxId)
  const txStatus = await fcl.tx(trxId).onceSealed()
  console.log(txStatus)
}

export const buildSetupTrx = async (key, args = []) => {
  const trxScript = await readCode(setup[key])
  const trxId = await sendTrx(trxScript, args)
  const txStatus = await fcl.tx(trxId).onceSealed()
  console.log(txStatus)
}

export const buildAndExecScript = async (key, args = []) => {
  const script = await readCode(scripts[key])
  const result = await execScript(script, args)
  return result
}

export const readCode = async (path) => {
  const data = fs.readFileSync(resolve(__dirname, path), 'utf-8')
  return data
}

export default {}
