import t from '@onflow/types'
import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'

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

const main = async () => {
  fclInit()
  // console.log('register domains with caos')
	// register
  // const res = await registerDomain(0, 'caoss', '3153600.00000000', '5.00000000')
	// renew
  const res1 = await renewDomain(0, 'caoss', '3153600.00000000', '0.70000000')
	// const nameHash = hash.hash('caoss.flow')
  // // const res = await buildAndExecScript('queryDomainRecord', [fcl.arg(nameHash, t.String)])
  // const res = await buildAndExecScript('queryDomainExpiredTime', [fcl.arg(nameHash, t.String)])
  // console.log(res)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
