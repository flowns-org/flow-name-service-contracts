import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript, buildAndSendTrx } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { accountAddr, flowTokenAddr } from '../config/constants.js'
import { test1Addr, test2Addr, test1Authz, test2Authz } from '../utils/authz.js'

export const mintFlowToken = async (address, amount) => {
  await buildSetupTrx('mintFlowToken', [fcl.arg(address, t.Address), fcl.arg(amount, t.UFix64)])
}

const main = async () => {
  // fcl init and load config
  fclInit()
  // mint token 50000
  await mintFlowToken(test1Addr, '1000.00000000')
  await mintFlowToken(test2Addr, '1000.00000000')
  const balance = await buildAndExecScript('queryFlowTokenBalance', [fcl.arg(test2Addr, t.Address)])
  console.log(balance)

  await buildSetupTrx('initTokens', [], test1Authz())
  await buildSetupTrx('initTokens', [], test2Authz())




  // await buildSetupTrx('mintKibbleToken', [
  //   fcl.arg(test1Addr, t.Address),
  //   fcl.arg('100.00', t.UFix64),
  // ])
  // await buildSetupTrx('mintKibbleToken', [
  //   fcl.arg(test2Addr, t.Address),
  //   fcl.arg('100.00', t.UFix64),
  // ])
  await buildSetupTrx('createFUSDMinter', [])
  await buildSetupTrx('mintFUSD', [fcl.arg(test1Addr, t.Address), fcl.arg('1000.00', t.UFix64)])
  await buildSetupTrx('mintFUSD', [fcl.arg(test2Addr, t.Address), fcl.arg('1000.00', t.UFix64)])


  // await buildSetupTrx('initDomainCollection', [], test1Authz())
  // await buildSetupTrx('initDomainCollection', [], test2Authz())
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
