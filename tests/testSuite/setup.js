import t from '@onflow/types'
import fcl from '@onflow/fcl'
import hash from 'eth-ens-namehash'
import dotenv from 'dotenv'
import moment from 'moment'
import { accountAddr } from '../../config/constants.js'
// import { checkTrxSealed } from './utils'
import { test1Authz, test2Authz, test1Addr, test2Addr } from '../../utils/authz'
import { buildAndExecScript, buildSetupTrx, fclInit, buildAndSendTrx } from '../../utils/index'
import { mintDomain, registerDomain } from '../../scripts/buildTrxs'

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

export const setupTest = () =>
  describe('Contract setup test cases', () => {
    beforeAll(() => {
      return fclInit()
      dotenv.config()
    })
    test('init admin resource failed', async () => {
      // check resource
      // const query = await buildAndExecScript('checkFlownsAdmin', [fcl.arg(accountAddr, t.Address)])
      // expect(query).toBe(true)
      const res = await buildSetupTrx('initFlownsAdminStorage')
      expect(res).toBeNull()
    })

    test('init admin cap with root domain collection', async () => {
      const res = await buildSetupTrx('setupAdminServer', [])
      expect(res).not.toBeNull()
      const { status } = res
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
      expect(query.name).toBe(flowName)
      expect(query.nameHash).toBe(flowNameHash)
      flowDomainId = query.id
      // check root domain number
      const domains = await buildAndExecScript('queryRootDomains')
      expect(domains[0]).not.toBeNull()
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
      expect(query.name).toBe(fnsName)
      expect(query.nameHash).toBe(fnsNameHash)
      fnsDomainId = query.id
      const domains = await buildAndExecScript('queryRootDomains')
      expect(domains[1]).not.toBeNull()
    })

    test('init flow && fns root domain server with domains collections', async () => {
      // check collection cap
      const query = await buildAndExecScript('checkDomainCollection', [
        fcl.arg(accountAddr, t.Address),
      ])
      expect(query).toBe(true)
      // set cap to flow root domain
      const res = await buildSetupTrx('setupRootDomainServer', [
        fcl.arg(0, t.UInt64),
      ])
      expect(res).not.toBeNull()
      expect(res.status).toBe(4)
      // set cap to fns root domain
      const res1 = await buildSetupTrx('setupRootDomainServer', [
        fcl.arg(1, t.UInt64),
      ])
      expect(res1).not.toBeNull()
      expect(res1.status).toBe(4)
    })
    // multi account needed
    // test('init root domain server with no permission will be failure', async () => {
    //   const res = await buildSetupTrx('initDomainCollection', [], test1Authz())
    //   expect(res).not.toBeNull()

    //   const res1 = await buildSetupTrx(
    //     'setupRootDomainServer',
    //     [fcl.arg(test1Addr, t.Address), fcl.arg(0, t.UInt64)],
    //     test1Authz(),
    //   )

    //   expect(res1).toBeNull()
    // })

    test('create domain with admin account', async () => {
      const timestamp = moment.now() / 1000
      const res = await mintDomain(flowDomainId, caosDomainName, flowName, oneMonth.toFixed(2))
      expect(res).not.toBeNull()
      expect(res.status).toBe(4)
      const query = await buildAndExecScript('queryRootDomainsById', [
        fcl.arg(flowDomainId, t.UInt64),
      ])
      expect(query.domainCount).toBe(1)

      const availableQuery = await buildAndExecScript('queryDomainAvailable', [
        fcl.arg(caosDomainNameHash, t.String),
      ])
      expect(availableQuery).toBe(false)

      const detail = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(caosDomainNameHash, t.String),
      ])

      console.log(detail)

      const timeQuery = await buildAndExecScript('queryDomainExpiredTime', [
        fcl.arg(caosDomainNameHash, t.String),
      ])
      expect(Number(timeQuery)).toBe(Math.floor(timestamp + oneMonth))
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

      expect(query[4]).toBe('0.00000020')
      expect(query[1]).toBe(undefined)
      expect(query[4]).not.toBe('0.0000003')

      const fnsRes = await buildSetupTrx('setupDomainRentPrice', [
        fcl.arg(fnsDomainId, t.UInt64),
        fcl.arg(4, t.Int),
        fcl.arg('0.0000001', t.UFix64),
      ])

      expect(fnsRes).not.toBeNull()
      expect(fnsRes.status).toBe(4)

      const fnsQuery = await buildAndExecScript('queryDomainRentPrice', [
        fcl.arg(fnsDomainId, t.UInt64),
      ])

      expect(fnsQuery[4]).toBe('0.00000010')
      expect(fnsQuery[1]).toBe(undefined)
      expect(fnsQuery[4]).not.toBe('0.0000003')
    })

    test('set price with no root domain', async () => {
      const res = await buildSetupTrx('setupDomainRentPrice', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(5, t.Int),
        fcl.arg('0.0000002', t.UFix64),
        test1Authz(),
      ])

      expect(res).toBeNull()
    })

    test('change root vault when it has blance', async () => {
      const timestamp = moment.now() / 1000

      const registerFailRes = await registerDomain(
        fnsDomainId,
        caosDomainName,
        fnsName,
        oneYear.toFixed(2),
        '3.10',
      )

      expect(registerFailRes).toBeNull()

      const pauseRes = await buildAndSendTrx('setFlownsPauseStatus', [fcl.arg(false, t.Bool)])

      expect(pauseRes).not.toBeNull()
      expect(pauseRes.status).toBe(4)

      const registerSuccessRes = await registerDomain(
        fnsDomainId,
        caosDomainName,
        fnsName,
        oneYear.toFixed(2),
        '3.10',
      )

      expect(registerSuccessRes).not.toBeNull()
      expect(registerSuccessRes.status).toBe(4)

      const query = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(caosFnsDomainNamHash, t.String),
      ])

      expect(query.name).toBe(`${caosDomainName}.${fnsName}`)
      expect(query.nameHash).toBe(caosFnsDomainNamHash)
      expect(query.parentName).toBe(fnsName)
      expect(Number(query.expiredAt)).toBeGreaterThanOrEqual(Math.floor(timestamp + oneYear))

      const balanceQuery = await buildAndExecScript('queryRootDomainVaultBalance', [
        fcl.arg(fnsDomainId, t.UInt64),
      ])
      expect(Number(balanceQuery)).toBe(3.1)

      const changeVaultRes = await buildAndSendTrx('changeRootDomainVaultWithFusd', [
        fcl.arg(fnsDomainId, t.UInt64),
      ])
      expect(changeVaultRes).toBeNull()

      const withdrawRes = await buildAndSendTrx('withdrawRootVault', [
        fcl.arg(fnsDomainId, t.UInt64),
        fcl.arg('3.10', t.UFix64),
      ])
      expect(withdrawRes).not.toBeNull()
      expect(withdrawRes.status).toBe(4)

      const balQuery = await buildAndExecScript('queryRootDomainVaultBalance', [
        fcl.arg(fnsDomainId, t.UInt64),
      ])
      expect(Number(balQuery)).toBe(0.0)

      const changeVaultAgainRes = await buildAndSendTrx('changeRootDomainVaultWithFusd', [
        fcl.arg(fnsDomainId, t.UInt64),
      ])
      expect(changeVaultAgainRes).not.toBeNull()
      expect(changeVaultAgainRes.status).toBe(4)

      await buildSetupTrx('setupDomainRentPrice', [
        fcl.arg(fnsDomainId, t.UInt64),
        fcl.arg(4, t.Int),
        fcl.arg('0.0000001', t.UFix64),
      ])

      const registerAgainRes = await registerDomain(
        fnsDomainId,
        'fail',
        fnsName,
        oneYear.toFixed(2),
        '3.10',
      )
      expect(registerAgainRes).toBeNull()
    })
  })
