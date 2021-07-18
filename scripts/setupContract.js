import t from '@onflow/types'
import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { accountAddr } from '../config/constants.js'

const main = async () => {
  // fcl init and load config
  fclInit()
  // init admin storage 
  await buildAndSendTrx('initFlownsAdminStorage')
  // setup admin cap
  await buildAndSendTrx('setupAdminServer', [fcl.arg(accountAddr, t.Address)])
  // mint flow root domain
  await buildAndSendTrx('mintFlowRootDomain')
  // setup root domain
  await buildAndSendTrx('setupRootDomainServer', [
    fcl.arg(accountAddr, t.Address),
    fcl.arg(0, t.UInt64),
  ])
  // set 5 len of domain name rent price
  await buildAndSendTrx('setupDomainRentPrice', [
    fcl.arg(0, t.UInt64),
    fcl.arg(5, t.Int),
    fcl.arg('4.00000000', t.UFix64),
  ])


  // const dmoain = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
  // console.log(dmoain)
  const dmoains = await buildAndExecScript('queryRootDomains')
  console.log(dmoains, 'domains')
  const res = await buildAndExecScript('checkDomainCollection', [fcl.arg(accountAddr, t.Address)])
  console.log(res)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
