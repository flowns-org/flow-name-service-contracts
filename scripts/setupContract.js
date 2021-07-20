import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { accountAddr } from '../config/constants.js'

const main = async () => {
  // fcl init and load config
  fclInit()
  // init admin storage
  await buildSetupTrx('initFlownsAdminStorage')
  // setup admin cap
  await buildSetupTrx('setupAdminServer', [fcl.arg(accountAddr, t.Address)])
  // mint flow root domain
  await buildSetupTrx('mintFlowRootDomain')
  // setup root domain
  await buildSetupTrx('setupRootDomainServer', [
    fcl.arg(accountAddr, t.Address),
    fcl.arg(0, t.UInt64),
  ])
  // set 5 len of domain name rent price
  await buildSetupTrx('setupDomainRentPrice', [
    fcl.arg(0, t.UInt64),
    fcl.arg(5, t.Int),
    fcl.arg('0.0000002', t.UFix64),
  ])

  // const dmoain = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
  // console.log(dmoain)
  const dmoains = await buildAndExecScript('queryRootDomains')
  console.log(dmoains, 'domains')
  const checkCollection = await buildAndExecScript('checkDomainCollection', [
    fcl.arg(accountAddr, t.Address),
  ])
  console.log(checkCollection)
  const prices = await buildAndExecScript('queryDomainRentPrice', [fcl.arg(0, t.UInt64)])
  console.log(prices)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
