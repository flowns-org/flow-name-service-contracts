import t from '@onflow/types'
import fcl from '@onflow/fcl'
import { fclInit, buildAndSendTrx, buildAndExecScript } from '../utils/index.js'
import { accountAddr } from '../config/constants.js'
import { test1Addr, test2Addr, test1Authz } from '../utils/authz.js'
import { namehash, normalize } from '../utils/hash.js'

const main = async () => {
  fclInit()
  // console.log('register domains with caos')
  // register
  // const result = await registerDomain(0, 'caosa','flow' '3153600.00000000', '5.00000000')
  // renew
  // const res1 = await renewDomain(0, 'caoss','flow', '3153600.00000000', '0.70000000')
  // const flowNamehash = namehash('caos.flow')
  // const fnsNameHash = namehash('caos.fns')
  // const domains = await buildAndExecScript('queryRootDomains')
  // console.log(domains)

  // const flowDetail = await buildAndExecScript('queryDomainInfo', [
  //   fcl.arg(flowNamehash, t.String),
  // ])
  // console.log(flowDetail)


  // const fnsDetail = await buildAndExecScript('queryDomainInfo', [
  //   fcl.arg(fnsNameHash, t.String),
  // ])
  // console.log(fnsDetail)
  const userDomain = await buildAndExecScript('queryUsersAllDomain', [fcl.arg(test1Addr, t.Address)])
  // const userDomain = await buildAndExecScript('queryDomainInfo', [fcl.arg(namehash('depr.flow'), t.String)])

  console.log(userDomain.length)

  // console.log(namehash('depr.flow'))

  // const res = await buildAndExecScript('queryIsDeprecated', [fcl.arg(namehash('depr.flow'), t.String), fcl.arg(14, t.UInt64)])
  // console.log(res)

  // const transferRes = await buildAndSendTrx(
  //   'transferDomainWithHashName',
  //   [fcl.arg(namehash('depr.flow'), t.String), fcl.arg(accountAddr, t.Address)],
  //   test1Authz(),
  // )
  // console.log(transferRes)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
