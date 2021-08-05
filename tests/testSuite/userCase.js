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

const userDomainName = 'user'
let userDomainNameHash = hash.hash(`${userDomainName}.${flowName}`)
let userFnsDomainNamHash = hash.hash(`${userDomainName}.${fnsName}`)
const devDomainName = 'dev'
let devDomainNameHash = hash.hash(`${devDomainName}.${flowName}`)

// user test case ,must init env with run node scripts/setupEnv.js first
export const userTest = () =>
  describe('user test cases', () => {
    beforeAll(() => {
      return fclInit()
      dotenv.config()
    })

    test('init domain fail with test1Authz', async () => {
      // check resource
      const setupTest1Res = await buildSetupTrx('initDomainCollection', [], test1Authz())
      expect(setupTest1Res).not.toBeNull()
      expect(setupTest1Res.status).toBe(4)

      const setuptest2Res = await buildSetupTrx('initDomainCollection', [], test2Authz())
      expect(setuptest2Res).not.toBeNull()
      expect(setuptest2Res.status).toBe(4)

      const res = await buildSetupTrx('initFlownsAdminStorage')
      expect(res).toBeNull()
    })
  })
