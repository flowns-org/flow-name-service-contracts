import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript, buildAndSendTrx } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { namehash } from '../utils/hash.js'
import { accountAddr } from '../config/constants.js'
import { registerDomain, renewDomain } from './buildTrxs.js'

const main = async () => {
  // fcl init and load config
  fclInit()

  
  
  // setup admin cap
  await buildSetupTrx('setupAdminServer', [fcl.arg(accountAddr, t.Address)])
  // mint flow root domain
  // await buildSetupTrx('mintRootDomain', [fcl.arg('flow', t.String)])




  // setup root domain
  await buildSetupTrx('setupRootDomainServer', [
    fcl.arg(accountAddr, t.Address),
    fcl.arg(0, t.UInt64),
  ])
  // set 5 len of domain name rent price
  await buildSetupTrx('setupDomainRentPrice', [
    fcl.arg(0, t.UInt64),
    fcl.arg(5, t.Int),
    fcl.arg('0.00000001', t.UFix64),
  ])


  await buildAndSendTrx('setFlownsPauseStatus', [fcl.arg(false, t.Bool)])

  const nameHash = namehash('caoss.flow')
  const result = await registerDomain(0, 'caoss', '3153600.00000000', '5.00000000')
  // renew
  await renewDomain(0, 'caoss', '3153600.00000000', '0.70000000')

  await registerDomain(0, 'testt', '3153600.00000000', '5.00000000')
  await registerDomain(0, 'caosa', '3153600.00000000', '5.00000000')
  await registerDomain(0, 'caosb', '3153600.00000000', '5.00000000')

  const subdomainHash = namehash('blog.caoss.flow')
  const res1 = await buildAndSendTrx('mintSubdomain', [
    fcl.arg(nameHash, t.String),
    fcl.arg('blog', t.String),
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

  const prices2 = await buildAndExecScript('queryDomainRentPrice', [fcl.arg(1, t.UInt64)])
  console.log(prices2)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
