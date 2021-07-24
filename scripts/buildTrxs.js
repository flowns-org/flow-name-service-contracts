import t from '@onflow/types'
import hash from 'eth-ens-namehash'
import fcl from '@onflow/fcl'

import { buildAndSendTrx, buildAndExecScript } from '../utils/index.js'

export const queryScript = async () => {
  const result = await buildAndExecScript('checkDomainCollection', [
    fcl.arg('0xf8d6e0586b0a20c7', t.Address),
  ])
  console.log(result)
}

export const registerDomain = async (domainId, name, duration, amount) => {
  const domainName = `${name}.flow`
  const nameHash = hash.hash(domainName)

  await buildAndSendTrx('registerDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(name, t.String),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
    fcl.arg(amount, t.UFix64),
  ])
}

export const renewDomain = async (domainId, name, duration, amount) => {
  const domainName = `${name}.flow`
  const nameHash = hash.hash(domainName)

  await buildAndSendTrx('renewDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
    fcl.arg(amount, t.UFix64),
  ])
}

export const mintDomain = async (domainId, name, duration) => {
  const domainName = `${name}.flow`
  const nameHash = hash.hash(domainName)
  await buildAndSendTrx('mintDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(name, t.String),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
  ])
}
