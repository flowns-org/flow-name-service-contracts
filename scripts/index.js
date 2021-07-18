import t from '@onflow/types'
import { fclInit, readCode, sendTrx } from '../utils/index.js'
import { paths } from '../config/constants.js'
import fcl from '@onflow/fcl'

// file paths
const { setup } = paths
// fcl init
fclInit()

// export const setupDomainsCollection = async () => {
//   const initDomainCollectionCode = await readCode(setup['initDomainCollection'])
//   const trxId = await sendTrx(initDomainCollectionCode, [])
//   console.log(trxId)
//   const txStatus = await fcl.tx(trxId).onceSealed()
//   console.log(txStatus)
// }

// export const initFlownsAdminStorage = async () => {
//   const initFlownsAdminStorage = await readCode(setup['initFlownsAdminStorage'])
//   const trxId = await sendTrx(initFlownsAdminStorage, [])
//   console.log(trxId)
//   const txStatus = await fcl.tx(trxId).onceSealed()
//   console.log(txStatus)
// }
