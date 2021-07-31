import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'
import dotenv from 'dotenv'
import { accountAddr } from '../config/constants.js'
// import { checkTrxSealed } from './utils'
import { test1Authz, test2Authz, test1Addr, test2Addr } from '../utils/authz'
import { buildAndExecScript, buildSetupTrx, fclInit, buildAndSendTrx } from '../utils/index'
import { mintDomain } from '../scripts/buildTrxs'

const oneYear = 60 * 60 * 24 * 265
const oneMonth = 60 * 60 * 24 * 30

const flowName = 'flow'
const flowNameHash = hash.hash(flowName)
let flowDomainId = 0
const fnsName = 'fns'
const fnsNameHash = hash.hash(fnsName)
let fnsDomainId = 0

const caosDomainName = 'caos'
let caosDomainNameHash = ''

const devDomainName = 'dev'
let devDomainNameHash = ''

describe('Contract setup test cases', () => {
  beforeAll(() => {
    return fclInit()
    dotenv.config()
  })
  test('init admin resource', async () => {
    // check resource
    const query = await buildAndExecScript('checkFlownsAdmin', [fcl.arg(accountAddr, t.Address)])
    expect(query).toBe(true)
    const res = await buildSetupTrx('initFlownsAdminStorage')
    expect(res).toBeNull()
  })

  test('init admin cap with root domain collection', async () => {
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
    const query = await buildAndExecScript('queryRootDomainsById', [fcl.arg(0, t.UInt64)])
    expect(query).not.toBe(null)
    expect(query.id).toBe(0)
    expect(query.name).toBe('flow')
    flowDomainId = query.id
  })

  test('create fns root domain', async () => {
    const res = await buildSetupTrx('mintRootDomain', [
      fcl.arg(fnsName, t.String),
      fcl.arg(fnsNameHash, t.String),
    ])
    expect(res).not.toBeNull()
    const { status } = res
    expect(status).toBe(4)

    const query = await buildAndExecScript('queryRootDomainsById', [fcl.arg(1, t.UInt64)])
    expect(query).not.toBe(null)
    expect(query.id).toBe(1)
    expect(query.name).toBe('fns')
    fnsDomainId = query.id
  })

  test('init flow && fns root domain server with domains collections', async () => {
    // check collection cap
    const query = await buildAndExecScript('checkDomainCollection', [
      fcl.arg(accountAddr, t.Address),
    ])
    expect(query).toBe(true)
    const res = await buildSetupTrx('setupRootDomainServer', [
      fcl.arg(accountAddr, t.Address),
      fcl.arg(0, t.UInt64),
    ])
    expect(res).not.toBeNull()
    expect(res.status).toBe(4)
    const res1 = await buildSetupTrx('setupRootDomainServer', [
      fcl.arg(accountAddr, t.Address),
      fcl.arg(1, t.UInt64),
    ])
    expect(res1).not.toBeNull()
    expect(res1.status).toBe(4)
  })

  test('init root domain server with no permission will be failure', async () => {
    const res = await buildSetupTrx('initDomainCollection', [], test1Authz())
    expect(res).not.toBeNull()

    const res1 = await buildSetupTrx(
      'setupRootDomainServer',
      [fcl.arg(test1Addr, t.Address), fcl.arg(0, t.UInt64)],
      test1Authz(),
    )

    expect(res1).toBeNull()
  })

  test('create domain with admin account', async () => {
    const domainName = 'caos'
    const res = await mintDomain(flowDomainId, domainName, oneMonth)
    expect(res).not.toBeNull()
    expect(res.status).toBe(4)

    const query = await buildAndExecScript('queryRootDomainsById', [
      fcl.arg(flowDomainId, t.UInt64),
    ])
    expect(query.domainCount).toBe(1)

    const query1 = await buildAndExecScript('queryDomainAvailable', [
      fcl.arg(flowDomainId, t.UInt64),
      fcl.arg(),
    ])
    expect(query.domainCount).toBe(1)
  })

  test('set price with root domain', async () => {
    const res = await buildSetupTrx('setupDomainRentPrice', [
      fcl.arg(flowDomainId, t.UInt64),
      fcl.arg(4, t.Int),
      fcl.arg('0.0000002', t.UFix64),
    ])

    expect(res).not.toBeNull()
    expect(res.status).toBe(4)

    const query = await buildAndExecScript('queryDomainRentPrice', [
      fcl.arg(flowDomainId, t.UInt64),
    ])

    expect(query[4]).toBe(0.0000002)
    expect(query[1]).toBeNull()
    expect(query[4]).not.toBe(0.0000003)
  })
})
