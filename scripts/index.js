import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'

import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import { accountAddr } from '../config/constants.js'
import { registerDomain, renewDomain, mintDomain } from './buildTrxs.js'

const main = async () => {
  fclInit()
  // console.log('register domains with caos')
  // register
  // const result = await registerDomain(0, 'caosa','flow' '3153600.00000000', '5.00000000')
  // renew
  // const res1 = await renewDomain(0, 'caoss','flow', '3153600.00000000', '0.70000000')
  const nameHash = hash.hash('caoss.flow')

  // get domain info by hashname
  // const domain = await buildAndExecScript('queryDomainInfo', [
  //   fcl.arg(nameHash, t.String),
  // ])
  // console.log(domain)

  // get user all info
  const subdomainHash = hash.hash('blog.caoss.flow')
  // await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('remove', t.String),
  //   fcl.arg(subdomainHash, t.String),
  // ])

  // set domain
  // await buildAndSendTrx('setDomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg('0x91a20a7e25a35415', t.String),
  // ])
  // await buildAndSendTrx('setDomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(2, t.UInt64),
  //   fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
  // ])

  // remove text
  // await buildAndSendTrx('removeDomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(2, t.UInt64),
  // ])

  // remove subdomain
  // await buildAndSendTrx('removeSubdomain', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
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
  // remove text
  // await buildAndSendTrx('removeDomainText', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg('github', t.String),
  // ])

  // await buildAndSendTrx('setSubdomainText', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
  //   fcl.arg('twitter', t.String),
  //   fcl.arg('@caosbad', t.String),
  // ])

  // await buildAndSendTrx('setSubdomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
  // ])

  // await buildAndSendTrx('setSubdomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('0x91a20a7e25a35415', t.String),
  // ])

  // await buildAndSendTrx('removeSubdomainText', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
  //   fcl.arg('twitter', t.String),
  // ])

  // await buildAndSendTrx('removeSubdomainAddress', [
  //   fcl.arg(nameHash, t.String),
  //   fcl.arg(subdomainHash, t.String),
  //   fcl.arg(1, t.UInt64),
  // ])
  const shortNameHash = hash.hash('caosine.flow')

  // await mintDomain(0, 'caosine', '87000.00000000')

  // const balance = await buildAndExecScript('queryFlowTokenBalance', [fcl.arg(accountAddr, t.Address)])
  // console.log(balance)

  // withdraw vault
  // await buildAndSendTrx('withdrawRootVault', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('1.00000000', t.UFix64),
  // ])

  // const res = await buildAndExecScript('queryRootDomainVaultBalance', [fcl.arg(0, t.UInt64)])

  const res4 = await buildAndExecScript('queryUsersAllDomain', [fcl.arg(accountAddr, t.Address)])
  console.log(res4)
  const res = await buildAndExecScript('queryUsersAllSubDomain', [
    fcl.arg(accountAddr, t.Address),
    fcl.arg(nameHash, t.String),
  ])
  console.log(res)

  // const res1 = await buildAndExecScript('queryDomainRecord', [fcl.arg(nameHash, t.String)])
  // console.log(res1)
  // const res2 = await buildAndExecScript('queryDomainExpiredTime', [fcl.arg(shortNameHash, t.String)])
  // console.log(res2)

  // const res3 = await buildAndExecScript('queryDomainExpired', [fcl.arg(shortNameHash, t.String)])
  // console.log(res3)
  // const dmoain = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
  // console.log(dmoain)
  // const res = await buildAndExecScript('queryDomainAvailable', [fcl.arg(nameHash, t.String)])
  // console.log(res)

  // query root vault

  // query withdraw root vault
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
