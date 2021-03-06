import t from '@onflow/types'
import hash from 'eth-ens-namehash'
import fcl from '@onflow/fcl'

import { buildAndSendTrx, buildAndExecScript } from '../utils/index.js'

export const registerDomain = async (
  domainId,
  name,
  duration,
  amount,
  authz = null,
  token = 'flow',
  refer = '0xf8d6e0586b0a20c7',
) => {
  const res = await buildAndSendTrx(
    token == 'flow' ? 'registerDomain' : 'registerDomainWithFUSD',
    [
      fcl.arg(domainId, t.UInt64),
      fcl.arg(name, t.String),
      fcl.arg(duration, t.UFix64),
      fcl.arg(amount, t.UFix64),
      fcl.arg(refer, t.Address),
    ],
    authz ? authz : undefined,
    600,
  )
  return res
}

export const renewDomain = async (domainId, nameHash, duration, amount, authz = null) => {
  

  const res = await buildAndSendTrx(
    'renewDomain',
    [
      fcl.arg(domainId, t.UInt64),
      fcl.arg(nameHash, t.String),
      fcl.arg(duration, t.UFix64),
      fcl.arg(amount, t.UFix64),
    ],
    authz ? authz : undefined,
  )
  return res
}

export const mintDomain = async (domainId, name, duration) => {
  const res = await buildAndSendTrx('mintDomain', [
    fcl.arg(domainId, t.UInt64),
    fcl.arg(name, t.String),
    fcl.arg(duration, t.UFix64),
  ])
  return res
}
