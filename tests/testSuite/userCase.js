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

const oneYear = 60 * 60 * 24 * 365
const oneMonth = 60 * 60 * 24 * 30

const flowName = 'flow'
const flowNameHash = hash.hash(flowName)
let flowDomainId = 0
const fnsName = 'fns'
const fnsNameHash = hash.hash(fnsName)
let fnsDomainId = 1

const test1DomainName = 'tes1'
let test1DomainNameHash = hash.hash(`${test1DomainName}.${flowName}`)
const test2DomainName = 'tes2'
let test2FnsDomainNamHash = hash.hash(`${test2DomainName}.${fnsName}`)

// const devDomainName = 'dev'
// let devDomainNameHash = hash.hash(`${devDomainName}.${flowName}`)

// user test case ,must init env with run node scripts/setupEnv.js first
export const userTest = () =>
  describe('user test cases', () => {
    beforeAll(() => {
      return fclInit()
      dotenv.config()
    })

    test('init domain collection with test1Authz and test2Authz', async () => {
      // check resource
      const setupTest1Res = await buildSetupTrx('initDomainCollection', [], test1Authz())
      expect(setupTest1Res).not.toBeNull()
      expect(setupTest1Res.status).toBe(4)

      const setuptest2Res = await buildSetupTrx('initDomainCollection', [], test2Authz())
      expect(setuptest2Res).not.toBeNull()
      expect(setuptest2Res.status).toBe(4)
    })

    test('register domain with less one year', async () => {
      // check resource
      const res = await registerDomain(
        flowDomainId,
        'tes1',
        flowName,
        '86400.00',
        '6.4',
        test1Authz(),
      )
      expect(res).toBeNull()
    })

    test('register domain with not enough token', async () => {
      // check resource
      const res = await registerDomain(
        flowDomainId,
        'tes1',
        flowName,
        oneYear.toFixed(2),
        '3.2',
        test1Authz(),
      )
      expect(res).toBeNull()
    })

    test('register domain with not price set', async () => {
      // check resource
      const res = await registerDomain(
        flowDomainId,
        'test1',
        flowName,
        oneYear.toFixed(2),
        '1',
        test1Authz(),
      )
      expect(res).toBeNull()
    })

    test('register domain with test1 and test2', async () => {
      const test1Bal = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(test1Addr, t.Address),
      ])
      const test2Bal = await buildAndExecScript('queryFUSDBalance', [
        fcl.arg(test2Addr, t.Address),
      ])
      // check resource
      const test1Reg = await registerDomain(
        flowDomainId,
        test1DomainName,
        flowName,
        oneYear.toFixed(2),
        '6.4',
        test1Authz(),
      )

      const test2Reg = await registerDomain(
        fnsDomainId,
        test2DomainName,
        fnsName,
        oneYear.toFixed(2),
        '3.2',
        test2Authz(),
        'FUSD'
      )
      expect(test1Reg).not.toBeNull()
      expect(test1Reg.status).toBe(4)

      expect(test2Reg).not.toBeNull()
      expect(test2Reg.status).toBe(4)
      const test1BalAfter = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(test1Addr, t.Address),
      ])
      const test2BalAfter = await buildAndExecScript('queryFUSDBalance', [
        fcl.arg(test2Addr, t.Address),
      ])
      expect(Number(test1BalAfter)).toBe(test1Bal - 6.4)
      expect(Number(test2BalAfter)).toBe(test2Bal - 3.2)
    })

    test('register duplicate domain ', async () => {
      const res = await buildAndExecScript('queryDomainAvailable', [
        fcl.arg(test1DomainNameHash, t.String),
      ])
      expect(res).toBe(false)

      const regRes = await registerDomain(
        flowDomainId,
        'tes1',
        flowName,
        oneYear.toFixed(2),
        '6.5',
        test2Authz(),
      )
      expect(regRes).toBeNull()
    })
  })
