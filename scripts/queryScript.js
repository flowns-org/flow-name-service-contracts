import t from '@onflow/types'
import { buildAndExecScript } from '../utils/index.js'
import fcl from '@onflow/fcl'

export const queryScript = async () => {
  const result = await buildAndExecScript('checkDomainCollection', [
    fcl.arg('0xf8d6e0586b0a20c7', t.Address),
  ])
  console.log(result)
}
