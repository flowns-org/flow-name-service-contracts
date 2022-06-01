import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript, buildAndSendTrx } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { namehash } from '../utils/hash.js'
import { accountAddr } from '../config/constants.js'
import { registerDomain, renewDomain } from './buildTrxs.js'

const flowName = 'flow'
const flowHash = namehash(flowName)

const nftName = 'nft'
const nftHash = namehash('nft')

const main = async () => {
  // fcl init and load config
  fclInit()

  // setup admin cap
  // const setupRes = await buildSetupTrx('setupAdminServer', [])
  // console.log(setupRes)
  // // mint root domain
  // const flowRes = await buildSetupTrx('mintRootDomain', [fcl.arg('meow', t.String)])
  // console.log('mint meow root name', flowRes)
  // // const nftRes = await buildSetupTrx('mintRootDomain', [fcl.arg(nftName, t.String)])
  // // console.log('mint nft root name', nftRes)

  // // setup flow root  domain
  await buildSetupTrx('setupRootDomainServer', [
    fcl.arg(1, t.UInt64),
  ])

  // // setup nft root domain
  // await buildSetupTrx('setupRootDomainServer', [
  //   fcl.arg(0, t.UInt64),
  // ])

  // set 4 len of domain name rent price
  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(4, t.Int),
  //   fcl.arg('0.00000015', t.UFix64),
  // ])

  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(3, t.Int),
  //   fcl.arg('0.0000003', t.UFix64),
  // ])

  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(5, t.Int),
  //   fcl.arg('0.00000005', t.UFix64),
  // ])


  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(6, t.Int),
  //   fcl.arg('0.00000001', t.UFix64),
  // ])

  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(7, t.Int),
  //   fcl.arg('0.00000001', t.UFix64),
  // ])


  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(8, t.Int),
  //   fcl.arg('0.00000001', t.UFix64),
  // ])

  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(9, t.Int),
  //   fcl.arg('0.00000001', t.UFix64),
  // ])

  // await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(10, t.Int),
  //   fcl.arg('0.00000001', t.UFix64),
  // ])


  // await buildAndSendTrx('setFlownsPauseStatus', [fcl.arg(false, t.Bool)])

  // const nameHash = namehash('caos.flow')
  // const result = await registerDomain(0, 'caos', '3153600.00000000', '5.00000000')

  // console.log('registerDomain', result)
  // renew
  // await renewDomain(0, namehash('caos.flow'), '6307200.00000000', '6.40000000')

  // await registerDomain(1, 'caos', '3153600.00000000', '3.20000000')

  // const subdomainHash = namehash('blog.caos.flow')
  // const res1 = await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('blog', t.String),
  // ])

  // console.log('mint', subdomainHash)

  // set domain
  // await buildAndSendTrx('setDomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg('0x91a20a7e25a35415', t.String),
  // ])

  // set text
  // await buildAndSendTrx('setDomainText', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('twitter', t.String),
  //   fcl.arg('@caosbad', t.String),
  // ])

  // await buildAndSendTrx('setDomainText', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('github', t.String),
  //   fcl.arg('@caosbad', t.String),
  // ])

  // const dmoain = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
  // console.log(dmoain)
  const dmoains = await buildAndExecScript('queryRootDomains')
  console.log(dmoains, 'domains')
  // const checkCollection = await buildAndExecScript('checkDomainCollection', [
  //   fcl.arg(accountAddr, t.Address),
  // ])
  // console.log('checkCollection' , checkCollection)
  // const prices = await buildAndExecScript('queryDomainRentPrice', [fcl.arg(0, t.UInt64)])
  // console.log(prices)

  // const prices2 = await buildAndExecScript('queryDomainRentPrice', [fcl.arg(1, t.UInt64)])
  // console.log(prices2)

  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [fcl.arg(accountAddr, t.Address)])

  // console.log(userDomain)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
