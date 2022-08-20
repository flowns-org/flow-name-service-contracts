import t from '@onflow/types'
import fcl from '@onflow/fcl'
import { namehash, normalize } from '../../utils/hash.js'
import dotenv from 'dotenv'
import moment from 'moment'
import { accountAddr } from '../../config/constants.js'
import { sleep } from '../../utils/index.js'
import { test1Authz, test2Authz, test1Addr, test2Addr } from '../../utils/authz'
import {
  buildAndExecScript,
  buildSetupTrx,
  fclInit,
  buildAndSendTrx,
} from '../../utils/index'
import {
  mintDomain,
  registerDomain,
  renewDomain,
  renewDomainWithHash,
} from '../../scripts/buildTrxs'

const oneYear = 60 * 60 * 24 * 365
const oneMonth = 60 * 60 * 24 * 30

const flowName = 'flow'
const flowNameHash = namehash(flowName)
let flowDomainId = 0
const fnsName = 'fns'
const fnsNameHash = namehash(fnsName)
let fnsDomainId = 1

const test1DomainName = 'tes1'
let test1DomainNameHash = namehash(`${test1DomainName}.${flowName}`)
const test2DomainName = 'tes2'
let test2FnsDomainNamHash = namehash(`${test2DomainName}.${fnsName}`)
const deprecatedDomainName = 'depr'
const deprecatedDomainNameHash = namehash(`${deprecatedDomainName}.${flowName}`)
const deprecatedSubDomain = 'sub'
const deprecatedSubDomainHash = namehash(
  `${deprecatedSubDomain}.${deprecatedDomainName}.${flowName}`,
)
// const devDomainName = 'dev'
// let devDomainNameHash = namehash(`${devDomainName}.${flowName}`)

// user test case ,must init env with run node scripts/setupEnv.js first
export const userTest = () =>
  describe('user test cases', () => {
    beforeAll(() => {
      return fclInit()
      dotenv.config()
    })

    test('init domain collection with test1Authz and test2Authz', async () => {
      // check resource
      const setupTest1Res = await buildSetupTrx(
        'initDomainCollection',
        [],
        test1Authz(),
      )
      expect(setupTest1Res).not.toBeNull()
      expect(setupTest1Res.status).toBe(4)

      const setuptest2Res = await buildSetupTrx(
        'initDomainCollection',
        [],
        test2Authz(),
      )
      expect(setuptest2Res).not.toBeNull()
      expect(setuptest2Res.status).toBe(4)
    })

    test('register domain with less one year', async () => {
      const res = await registerDomain(
        flowDomainId,
        'tes1',
        '86400.00',
        '6.4',
        test1Authz(),
      )
      expect(res).toBeNull()
    })

    test('register domain with not enough token', async () => {
      const res = await registerDomain(
        flowDomainId,
        'tes1',
        oneYear.toFixed(2),
        '3.2',
        test1Authz(),
      )
      expect(res).toBeNull()
    })

    test('register domain with not price set', async () => {
      const res = await registerDomain(
        flowDomainId,
        'test1',
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

      const test1Reg = await registerDomain(
        flowDomainId,
        test1DomainName,
        oneYear.toFixed(2),
        '6.40',
        test1Authz(),
      )

      const test2Reg = await registerDomain(
        fnsDomainId,
        test2DomainName,
        oneYear.toFixed(2),
        '3.20',
        test2Authz(),
        'FUSD',
      )
      expect(test1Reg).not.toBeNull()
      expect(test1Reg.status).toBe(4)

      const renewRes = await renewDomain(
        flowDomainId,
        test1DomainNameHash,
        oneYear.toFixed(2),
        '10.00',
        test1Authz(),
      )

      expect(renewRes).not.toBeNull()
      console.log(renewRes)
      expect(test2Reg).not.toBeNull()
      expect(test2Reg.status).toBe(4)
      const test1BalAfter = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(test1Addr, t.Address),
      ])
      const test2BalAfter = await buildAndExecScript('queryFUSDBalance', [
        fcl.arg(test2Addr, t.Address),
      ])
      expect(Number(test1BalAfter)).toBe(test1Bal - 16.4)
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
        oneYear.toFixed(2),
        '6.5',
        test2Authz(),
      )
      expect(regRes).toBeNull()
    })

    test('domain deprecated test case', async () => {
      const mintRes = await buildAndSendTrx('mintDomain', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(deprecatedDomainName, t.String),
        fcl.arg('1.00', t.UFix64),
      ])
      expect(mintRes).not.toBeNull()
      expect(mintRes.status).toBe(4)
      const queryRes = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      console.log(queryRes)
      const deprecatedId = queryRes.id
      const currentId = await buildAndExecScript('queryDomaimId', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      expect(deprecatedId).toBe(currentId)

      await sleep(1000)
      await buildAndSendTrx('setDomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(0, t.UInt64),
        fcl.arg('0xcea5e66bec5193e5ec0b049a3fe5d7dd896fd480', t.String),
      ])
      // await sleep(1000)
      await buildAndSendTrx('setDomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(1, t.UInt64),
        fcl.arg('0xcea5e66bec5193e5ec0b049a3fe5d7dd896fd480', t.String),
      ])
      await sleep(1000)

      const currentTime = await buildAndExecScript(
        'getCurrentBlockTimestamp',
        [],
      )
      console.log(currentTime, 'current time ')
      const res = await buildAndExecScript('queryDomainAvailable', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      expect(res).toBe(true)
      const test1Bal = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(test1Addr, t.Address),
      ])
      console.log(test1Bal, 'test1 flow bal')

      const regRes = await registerDomain(
        flowDomainId,
        deprecatedDomainName,
        oneYear.toFixed(2),
        '10.0',
        test1Authz(),
      )
      expect(regRes).not.toBeNull()
      expect(regRes.status).toBe(4)
      const newId = await buildAndExecScript('queryDomaimId', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      expect(Number(deprecatedId) + 1).toBe(Number(newId))
      const test1BalAfter = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(test1Addr, t.Address),
      ])
      expect(Number(test1BalAfter)).toBe(test1Bal - 10)

      const deprRes = await buildAndExecScript('queryDomainDeprecated', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])

      expect(deprRes).not.toBeNull()
      console.log(deprRes)
    })

    test('Deprecated domain change and renew fail ', async () => {
      const renewRes = await renewDomain(
        flowDomainId,
        deprecatedDomainNameHash,
        oneYear.toFixed(2),
        '10.00',
      )

      expect(renewRes).toBeNull()

      const setRes = await buildAndSendTrx('setDomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(0, t.UInt64),
        fcl.arg('0xcea5e66bec5193e5ec0b049a3fe5d7dd896fd480', t.String),
      ])
      expect(setRes).toBeNull()
    })

    test('Deprecated domain transfer fail ', async () => {
      const transferRes = await buildAndSendTrx('transferDomainWithHashName', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(test2Addr, t.Address),
      ])
      expect(transferRes).toBeNull()
    })

    test('Transfer renew domains to deprecate account', async () => {
      const beforeAddr = await buildAndExecScript('queryDomainRecord', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      expect(beforeAddr).toBe(test1Addr)

      const transferRes = await buildAndSendTrx(
        'transferDomainWithHashName',
        [
          fcl.arg(deprecatedDomainNameHash, t.String),
          fcl.arg(accountAddr, t.Address),
        ],
        test1Authz(),
      )
      expect(transferRes).not.toBeNull()
      expect(transferRes.status).toBe(4)

      const afterAddr = await buildAndExecScript('queryDomainRecord', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])
      expect(accountAddr).toBe(afterAddr)
    })

    test('Deprecate account manage domain and subdomain with same hash name', async () => {
      const setTextRes = await buildAndSendTrx('setDomainText', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg('text', t.String),
        fcl.arg('value', t.String),
      ])
      expect(setTextRes).not.toBeNull()
      expect(setTextRes.status).toBe(4)

      const subRes = await buildAndSendTrx('mintSubdomain', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomain, t.String),
      ])

      expect(subRes).not.toBeNull()
      expect(subRes.status).toBe(4)

      const setAddressRes = await buildAndSendTrx('setDomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(0, t.UInt64),
        fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
      ])
      expect(setAddressRes).not.toBeNull()
      expect(setAddressRes.status).toBe(4)

      const setRes = await buildAndSendTrx('setDomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(0, t.UInt64),
        fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
      ])
      expect(setRes).not.toBeNull()
      expect(setRes.status).toBe(4)

      const setSubText = await buildAndSendTrx('setSubdomainText', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomainHash, t.String),
        fcl.arg('subText', t.String),
        fcl.arg('subValue', t.String),
      ])
      expect(setSubText).not.toBeNull()
      expect(setSubText.status).toBe(4)
      // todo test
      const setSubAddr = await buildAndSendTrx('setSubdomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomainHash, t.String),
        fcl.arg(1, t.UInt64),
        fcl.arg('123', t.String),
      ])
      expect(setSubAddr).not.toBeNull()
      expect(setSubAddr.status).toBe(4)

      const domainQuery = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])

      expect(Number(domainQuery.subdomainCount)).toBe(1)
      expect(domainQuery.texts['text']).toBe('value')
      expect(domainQuery.addresses[0]).toBe(
        '0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480',
      )

      const subdomains = await buildAndExecScript('queryUsersAllSubDomain', [
        fcl.arg(accountAddr, t.Address),
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])

      const subdomainInfo = subdomains[0]

      expect(subdomainInfo).not.toBeNull()
      expect(subdomainInfo.texts['subText']).toBe('subValue')
      expect(subdomainInfo.addresses[1]).toBe('123')

      const removeSubTextRes = await buildAndSendTrx('removeSubdomainText', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomainHash, t.String),
        fcl.arg('subText', t.String),
      ])

      expect(removeSubTextRes).not.toBeNull()
      expect(removeSubTextRes.status).toBe(4)

      const removeSubAddrRes = await buildAndSendTrx('removeSubdomainAddress', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomainHash, t.String),
        fcl.arg(1, t.UInt64),
      ])

      expect(removeSubAddrRes).not.toBeNull()
      expect(removeSubAddrRes.status).toBe(4)

      const subdomainsAfter = await buildAndExecScript(
        'queryUsersAllSubDomain',
        [
          fcl.arg(accountAddr, t.Address),
          fcl.arg(deprecatedDomainNameHash, t.String),
        ],
      )
      const subdomainInfo2 = subdomainsAfter[0]

      expect(subdomainInfo2).not.toBeNull()
      expect(subdomainInfo2.texts['subText']).toBe(undefined)
      expect(subdomainInfo2.addresses[1]).toBe(undefined)

      const removeSubdomain = await buildAndSendTrx('removeSubdomain', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(deprecatedSubDomainHash, t.String),
      ])

      expect(removeSubdomain).not.toBeNull()
      expect(removeSubdomain.status).toBe(4)

      const domainQueryAfter = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])

      expect(Number(domainQueryAfter.subdomainCount)).toBe(0)

      const domainsQuery = await buildAndExecScript('queryUsersAllDomain', [
        fcl.arg(accountAddr, t.Address),
      ])

      expect(domainsQuery.length).toBe(4)
      console.log(domainsQuery, '=======')
    })

    test('deposit flow to domain', async () => {
      const flowVaultType = 'A.0ae53cb6e3f42a79.FlowToken.Vault'
      await buildAndSendTrx('updateFTWhitelist', [
        fcl.arg(flowVaultType, t.String),
        fcl.arg(true, t.Bool),
      ])
      const collectionType = 'A.f8d6e0586b0a20c7.Domains.Collection'

      await buildAndSendTrx('updateNFTWhitelist', [
        fcl.arg(collectionType, t.String),
        fcl.arg(true, t.Bool),
      ])
      const test1FlowBal = await buildAndExecScript('queryFlowTokenBalance', [
        fcl.arg(accountAddr, t.Address),
      ])
      const depositRes = await buildAndSendTrx('depositDomainVaultWithFlow', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg('50.0', t.UFix64),
      ])
      expect(depositRes).not.toBeNull()
      expect(depositRes.status).toBe(4)

      const test1FlowBalAfter = await buildAndExecScript(
        'queryFlowTokenBalance',
        [fcl.arg(accountAddr, t.Address)],
      )

      expect(Number(test1FlowBalAfter)).toBe(test1FlowBal - 50)
      const beforeQuery = await buildAndExecScript('queryUsersAllDomain', [
        fcl.arg(accountAddr, t.Address),
      ])
      console.log(beforeQuery)
      expect(beforeQuery.length).toBe(4)

      const sendNFTRes = await buildAndSendTrx('sendNFTToDomain', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(0, t.UInt64),
      ])
      expect(sendNFTRes).toBeNull()
      // expect(sendNFTRes.status).toBe(4)

      const domainsQuery = await buildAndExecScript('queryUsersAllDomain', [
        fcl.arg(accountAddr, t.Address),
      ])
      expect(domainsQuery.length).toBe(4)

      const domainInfo = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(deprecatedDomainNameHash, t.String),
      ])

      expect(domainInfo.vaultBalances[flowVaultType]).not.toBeNull()
      expect(domainInfo.collections[collectionType]).not.toBeNull()

      let withdrawRes = await buildAndSendTrx('withdrawVaultWithVaultType', [
        fcl.arg(deprecatedDomainNameHash, t.String),
        fcl.arg(flowVaultType, t.String),
        fcl.arg('30.0', t.UFix64),
      ])

      // let withdrawNFTRes = await buildAndSendTrx('withdrawNFTFromDomain', [
      //   fcl.arg(deprecatedDomainNameHash, t.String),
      //   fcl.arg(collectionType, t.String),
      //   fcl.arg(0, t.UInt64),
      // ])
      console.log(withdrawRes)
      const domainsQueryAfter = await buildAndExecScript(
        'queryUsersAllDomain',
        [fcl.arg(accountAddr, t.Address)],
      )
      expect(domainsQueryAfter.length).toBe(4)

      const test1FlowBalLast = await buildAndExecScript(
        'queryFlowTokenBalance',
        [fcl.arg(accountAddr, t.Address)],
      )

      expect(Number(test1FlowBalLast)).toBe(test1FlowBal - 50 + 30)
    })

    test('test fns root domain forbid chars', async () => {
      const setRes = await buildAndSendTrx('setDomainForbidChars', [
        fcl.arg('. abc', t.String),
      ])

      expect(setRes).not.toBeNull()
      expect(setRes.status).toBe(4)

      const res1 = await registerDomain(
        fnsDomainId,
        'testflownamewitha',
        oneYear.toFixed(2),
        '100.0',
        test1Authz(),
        'FUSD',
      )
      expect(res1).toBeNull()

      const res2 = await registerDomain(
        fnsDomainId,
        'abcd',
        oneYear.toFixed(2),
        '100.0',
        test1Authz(),
        'FUSD',
      )
      expect(res2).toBeNull()

      const res3 = await registerDomain(
        fnsDomainId,
        'nil!',
        oneYear.toFixed(2),
        '10.0',
        test1Authz(),
        'FUSD',
      )
      expect(res3).not.toBeNull()
      expect(res3.status).toBe(4)

      const res4 = await registerDomain(
        fnsDomainId,
        'nil?',
        oneYear.toFixed(2),
        '10.0',
        test1Authz(),
        'FUSD',
      )
      expect(res4).not.toBeNull()
      expect(res4.status).toBe(4)
      await buildAndSendTrx('setDomainForbidChars', [
        fcl.arg('ABCDEFGHIJKLMNOPQRSTUVWXYZ.,', t.String),
      ])
    })

    test('test domain length ', async () => {
      const res = await registerDomain(
        flowDomainId,
        'thisisolen',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )

      expect(res).not.toBeNull()
      expect(res.status).toBe(4)

      const res1 = await registerDomain(
        flowDomainId,
        'thisisolenthisisolenthisisolen',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res1).not.toBeNull()
      expect(res1.status).toBe(4)

      const res2 = await registerDomain(
        flowDomainId,
        'thisisolenthisisolenthisisolen1',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res2).toBeNull()

      const setRes = await buildAndSendTrx('setRootDomainMaxLength', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(32, t.Int),
      ])

      expect(setRes).not.toBeNull()
      expect(setRes.status).toBe(4)

      const domainQuery1 = await buildAndExecScript('queryRootDomainsById', [
        fcl.arg(flowDomainId, t.UInt64),
      ])

      expect(Number(domainQuery1.maxDomainLength)).toBe(32)

      const res3 = await registerDomain(
        flowDomainId,
        'thisisolenthisisolenthisisolen1',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res3).not.toBeNull()
      expect(res3.status).toBe(4)

      const setRes2 = await buildAndSendTrx('setRootDomainMaxLength', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(9, t.Int),
      ])

      expect(setRes2).not.toBeNull()
      expect(setRes2.status).toBe(4)

      const domainQuery2 = await buildAndExecScript('queryRootDomainsById', [
        fcl.arg(flowDomainId, t.UInt64),
      ])

      expect(Number(domainQuery2.maxDomainLength)).toBe(9)

      const res4 = await registerDomain(
        flowDomainId,
        'thisisolen',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res4).toBeNull()

      await buildAndSendTrx('setRootDomainMaxLength', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(20, t.Int),
      ])
    })

    test('test fns root domain duration', async () => {
      const setRes = await buildAndSendTrx('setRootDomainMinRentDuration', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg('15768000.0', t.UFix64),
      ])

      expect(setRes).not.toBeNull()
      expect(setRes.status).toBe(4)

      const domainQuery = await buildAndExecScript('queryRootDomainsById', [
        fcl.arg(flowDomainId, t.UInt64),
      ])

      expect(Number(domainQuery.minRentDuration)).toBe(15768000)

      const res = await registerDomain(
        flowDomainId,
        'thisisolen1',
        (oneYear / 3).toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res).toBeNull()

      const res1 = await registerDomain(
        flowDomainId,
        'thisisolen1',
        (oneYear / 2 - 1).toFixed(2),
        '3.47',
        test1Authz(),
      )

      expect(res1).toBeNull()

      const res2 = await registerDomain(
        flowDomainId,
        'thisisolen1',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )
      expect(res2).not.toBeNull()
      expect(res2.status).toBe(4)

      const setRes1 = await buildAndSendTrx('setRootDomainMinRentDuration', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg(oneYear.toFixed(2), t.UFix64),
      ])

      expect(setRes1).not.toBeNull()
      expect(setRes1.status).toBe(4)

      const res3 = await registerDomain(
        flowDomainId,
        'thisisolen2',
        (oneYear - 2).toFixed(2),
        '3.47',
        test1Authz(),
      )

      expect(res3).toBeNull()

      const res4 = await registerDomain(
        flowDomainId,
        'thisisolen2',
        oneYear.toFixed(2),
        '3.47',
        test1Authz(),
      )

      expect(res4).not.toBeNull()
      expect(res4.status).toBe(4)
    })

    test('test fns root domain commissionRate', async () => {
      const flowVaultType = 'A.0ae53cb6e3f42a79.FlowToken.Vault'

      const setRes = await buildAndSendTrx('setRootDomainCommissionRate', [
        fcl.arg(flowDomainId, t.UInt64),
        fcl.arg('0.1', t.UFix64),
      ])

      expect(setRes).not.toBeNull()
      expect(setRes.status).toBe(4)

      const rootQuery = await buildAndExecScript('queryRootDomainsById', [
        fcl.arg(flowDomainId, t.UInt64),
      ])

      expect(Number(rootQuery.commissionRate)).toBe(0.1)

      const domainRes = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(namehash('tes2.fns'), t.String),
      ])
      const balanceBefore = domainRes.vaultBalances[flowVaultType] || 0

      const reg = await registerDomain(
        flowDomainId,
        'thisisolen10',
        oneYear.toFixed(2),
        '10.0',
        test1Authz(),
        'flow',
        '0x179b6b1cb6755e31',
      )

      expect(reg).not.toBeNull()
      expect(reg.status).toBe(4)

      const domainRes2 = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(namehash('tes2.fns'), t.String),
      ])
      const balanceAfter = domainRes2.vaultBalances[flowVaultType]

      expect(Number(balanceBefore)).toBe(Number(balanceAfter) - 1)

      const reg2 = await registerDomain(
        fnsDomainId,
        'thisisolen10',
        oneYear.toFixed(2),
        '10.0',
        test1Authz(),
        'FUSD',
      )
      expect(reg2).not.toBeNull()
      expect(reg2.status).toBe(4)

      const domainRes3 = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(namehash('tes2.fns'), t.String),
      ])
      const balance = domainRes3.vaultBalances[flowVaultType]

      expect(Number(balanceBefore)).toBe(Number(balance) - 1)
    })

    test('test fns renew domain with hash', async () => {
      const test1Domain = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(test1DomainNameHash, t.String),
      ])
      const { expiredAt } = test1Domain

      const renewRes = await renewDomainWithHash(
        test1DomainNameHash,
        oneYear.toFixed(2),
        '10.0',
        test2Authz(),
      )
      expect(renewRes).not.toBeNull()
      expect(renewRes.status).toBe(4)
      console.log(renewRes)
      const test1DomainAfter = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(test1DomainNameHash, t.String),
      ])
      const { expiredAt: expiredAfter } = test1DomainAfter

      console.log(expiredAt, expiredAfter)

      expect(Number(expiredAt) + oneYear).toBe(Number(expiredAfter))
    })

    test('test fns renew domain with admin', async () => {
      const test1Domain = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(test1DomainNameHash, t.String),
      ])
      const { expiredAt } = test1Domain

      const renewRes = await buildAndSendTrx('renewDomainWithAdmin', [
        fcl.arg(test1DomainNameHash, t.String),
        fcl.arg(oneMonth.toFixed(2), t.UFix64),
      ])
      expect(renewRes).not.toBeNull()
      expect(renewRes.status).toBe(4)
      console.log(renewRes)
      const test1DomainAfter = await buildAndExecScript('queryDomainInfo', [
        fcl.arg(test1DomainNameHash, t.String),
      ])
      const { expiredAt: expiredAfter } = test1DomainAfter

      console.log(expiredAt, expiredAfter)

      expect(Number(expiredAt) + oneMonth).toBe(Number(expiredAfter))
    })
  })
