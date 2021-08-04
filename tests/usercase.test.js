import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'
import dotenv from 'dotenv'
import moment from 'moment'
import { accountAddr } from '../config/constants.js'
// import { checkTrxSealed } from './utils'
import { test1Authz, test2Authz, test1Addr, test2Addr } from '../utils/authz'
import { buildAndExecScript, buildSetupTrx, fclInit, buildAndSendTrx } from '../utils/index'
import { mintDomain, registerDomain } from '../scripts/buildTrxs'

const oneYear = 60 * 60 * 24 * 265
const oneMonth = 60 * 60 * 24 * 30

const flowName = 'flow'
const flowNameHash = hash.hash(flowName)
let flowDomainId = 0
const fnsName = 'fns'
const fnsNameHash = hash.hash(fnsName)
let fnsDomainId = 0

const caosDomainName = 'caos'
let caosDomainNameHash = hash.hash(`${caosDomainName}.${flowName}`)
let caosFnsDomainNamHash = hash.hash(`${caosDomainName}.${fnsName}`)
const devDomainName = 'dev'
let devDomainNameHash = hash.hash(`${devDomainName}.${flowName}`)

describe('user test cases', () => {
  beforeAll(() => {
    return fclInit()
    dotenv.config()
  })
  test('register domain in flow root domain with test1Authz', async () => {
    // check resource
    const setupRes = await buildSetupTrx('initDomainCollection', [], test1Authz())
    expect(setupRes).not.toBeNull()
    expect(setupRes.status).toBe(4)
    
    const res = await buildSetupTrx('initFlownsAdminStorage')
    expect(res).toBeNull()
  })
})
