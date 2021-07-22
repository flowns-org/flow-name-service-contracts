import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'

import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import { accountAddr } from '../config/constants.js'
import { registerDomain, renewDomain } from './buildTrxs.js'

const main = async () => {
  fclInit()
  // console.log('register domains with caos')
  // register
  // const result = await registerDomain(0, 'caosa', '3153600.00000000', '5.00000000')
  // renew
  // const res1 = await renewDomain(0, 'caoss', '3153600.00000000', '0.70000000')
  const nameHash = hash.hash('caoss.flow')

  // get domain info by hashname
  // const domain = await buildAndExecScript('queryDomainInfo', [
  //   fcl.arg(nameHash, t.String),
  // ])
  // console.log(domain)

  // get user all info
  // const subdomainHash = hash.hash('dev.caoss.flow')
  // const res1 = await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('dev', t.String),
  //   fcl.arg(subdomainHash, t.String),
  // ])

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



  const res = await buildAndExecScript('queryUsersAllDomain', [fcl.arg(accountAddr, t.Address)])
  console.log(res)

  // const res1 = await buildAndExecScript('queryDomainRecord', [fcl.arg(nameHash, t.String)])
  // console.log(res1)
  // const res2 = await buildAndExecScript('queryDomainExpiredTime', [fcl.arg(nameHash, t.String)])
  // console.log(res2)
  // const dmoain = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
  // console.log(dmoain)
  // const res = await buildAndExecScript('queryDomainAvailable', [fcl.arg(0, t.UInt64), fcl.arg(nameHash, t.String)])
  // console.log(res)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
