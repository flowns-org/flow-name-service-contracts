import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'
import dotenv from 'dotenv'
import { accountAddr } from '../config/constants.js'
import { checkTrxSealed } from './utils'
import { test1Authz, test2Authz } from '../utils/authz'
import { buildAndExecScript, buildSetupTrx, fclInit } from '../utils/index'

const flowName = 'flow'
const flowNameHash = hash.hash(flowName)

const fnsName = 'fns'
const fnsNameHash = hash.hash(fnsName)

describe('Contract setup test cases', () => {
  beforeAll(() => {
    return fclInit()
    dotenv.config()
  })
  test('init admin resource', async () => {
    // check resource

    const res = await buildSetupTrx('initFlownsAdminStorage')
    expect(res).toBeNull()
  })

  test('init admin cap with root domain collection', async () => {
    // check collection cap
    const res = await buildSetupTrx('setupAdminServer', [fcl.arg(accountAddr, t.Address)])
    expect(res).not.toBeNull()
    const { status, events } = res
    // check
    expect(status).toBe(4)
  })

  test('create flow root domain', async () => {
    const res = await buildSetupTrx('mintRootDomain', [
      fcl.arg(flowName, t.String),
      fcl.arg(flowNameHash, t.String),
    ])
    expect(res).not.toBeNull()
    const { status } = res
    expect(status).toBe(4)
    // check root domain info
  })

  test('create fns root domain', async () => {
    const res = await buildSetupTrx('mintRootDomain', [
      fcl.arg(fnsName, t.String),
      fcl.arg(fnsNameHash, t.String),
    ])
    expect(res).not.toBeNull()
    const { status } = res
    expect(status).toBe(4)
  })
})
