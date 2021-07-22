import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript, buildAndSendTrx } from '../utils/index.js'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'
import { accountAddr } from '../config/constants.js'
import { registerDomain, renewDomain} from './buildTrxs.js'

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

  const nameHash = hash.hash('caoss.flow')
  const result = await registerDomain(0, 'caoss', '3153600.00000000', '5.00000000')
  // renew
  await renewDomain(0, 'caoss', '3153600.00000000', '0.70000000')

  const subdomainHash = hash.hash('blog.caoss.flow')
  const res1 = await buildAndSendTrx('mintSubdomain', [
    fcl.arg(nameHash, t.String),
    fcl.arg('dev', t.String),
    fcl.arg(subdomainHash, t.String),
  ])


    // set domain
  // await buildAndSendTrx('setDomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg('0x91a20a7e25a35415', t.String),
  // ])

  // set text
  await buildAndSendTrx('setDomainText', [
    fcl.arg(nameHash, t.String),
    fcl.arg('twitter', t.String),
    fcl.arg('@caosbad', t.String),
  ])

  await buildAndSendTrx('setDomainText', [
    fcl.arg(nameHash, t.String),
    fcl.arg('github', t.String),
    fcl.arg('@caosbad', t.String),
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
