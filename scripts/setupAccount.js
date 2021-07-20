import t from '@onflow/types'
import { fclInit, buildSetupTrx, buildAndExecScript } from '../utils/index.js'
import fcl from '@onflow/fcl'
import { accountAddr, flowTokenAddr } from '../config/constants.js'

export const mintFlowToken = async (address, amount) => {
  await buildSetupTrx('mintFlowToken', [fcl.arg(address, t.Address), fcl.arg(amount, t.UFix64)])
}

const main = async () => {
  // fcl init and load config
  fclInit()
  // mint token 50000
  // await mintFlowToken(accountAddr, '50000.00000000')
  const balance = await buildAndExecScript('queryFlowTokenBalance', [
    fcl.arg(accountAddr, t.Address),
  ])
  console.log(balance)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
