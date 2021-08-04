import t from '@onflow/types'
import hash from 'eth-ens-namehash'
import fcl from '@onflow/fcl'

import { buildAndSendTrx, buildAndExecScript } from '../utils/index.js'

export const registerDomain = async (domainId, name, rootName, duration, amount) => {
  const domainName = `${name}.${rootName}`
  const nameHash = hash.hash(domainName)
  console.log(name, nameHash)
  const res = await buildAndSendTrx('registerDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(name, t.String),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
    fcl.arg(amount, t.UFix64),
  ])
  return res
}

export const renewDomain = async (domainId, name, rootName, duration, amount) => {
  const domainName = `${name}.${rootName}`
  const nameHash = hash.hash(domainName)

  const res = await buildAndSendTrx('renewDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
    fcl.arg(amount, t.UFix64),
  ])
  return res
}

export const mintDomain = async (domainId, name, rootName, duration) => {
  const domainName = `${name}.${rootName}`
  const nameHash = hash.hash(domainName)
  const res = await buildAndSendTrx('mintDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(name, t.String),
    fcl.arg(nameHash, t.String),
    fcl.arg(duration, t.UFix64),
  ])
  return res
}
