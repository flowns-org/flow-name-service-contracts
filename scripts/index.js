import t from "@onflow/types";
import fcl from "@onflow/fcl";
import {
  fclInit,
  buildAndSendTrx,
  buildAndExecScript,
  buildSetupTrx,
} from "../utils/index.js";
import { registerDomain, renewDomain } from "./buildTrxs.js";
import { accountAddr } from "../config/constants.js";
import {
  test1Addr,
  test2Addr,
  test1Authz,
  test2Authz,
} from "../utils/authz.js";
import { namehash, normalize } from "../utils/hash.js";
import { query } from "../utils/index.js";
const oneYear = 60 * 60 * 24 * 365;
const oneHour = 60 * 20;
const flowVaultType = "A.7e60df042a9c0868.FlowToken.Vault";
const collectionType = "A.b05b2abb42335e88.Domains.Collection";

const main = async () => {
  fclInit();
  // await buildSetupTrx('initDomainCollection', [], test1Authz())
  // await buildSetupTrx('initDomainCollection', [], test2Authz())

  // mainnet
  // const price = await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(4, t.Int),
  //   fcl.arg('0.00000094', t.UFix64),
  // ])
  // console.log(price)

  // testnet
  // const price2 = await buildSetupTrx('setupDomainRentPrice', [
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg(4, t.Int),
  //   fcl.arg('0.00000094', t.UFix64),
  // ])
  // console.log(price2)

  // const paus = await buildAndSendTrx('setFlownsPauseStatus', [fcl.arg(false, t.Bool)])
  // console.log(paus)
  // const flowRes = await buildSetupTrx('mintRootDomain', [fcl.arg('fn', t.String)])
  // console.log('mint flow root name', flowRes)

  // setup flow root  domain
  // const setup = await buildSetupTrx('setupRootDomainServer', [fcl.arg(1, t.UInt64)])
  // console.log(setup)

  // console.log(namehash('test'))

  // const setRes1 = await buildAndSendTrx('setRootDomainMinRentDuration', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(oneYear.toFixed(2), t.UFix64),
  // ])

  // console.log(setRes1)

  // const setRes2 = await buildAndSendTrx('setRootDomainMinRentDuration', [
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg(oneYear.toFixed(2), t.UFix64),
  // ])
  // console.log(setRes2)

  // const setRes3 = await buildAndSendTrx('setRootDomainCommissionRate', [
  //   fcl.arg(1, t.UInt64),
  //   fcl.arg('0.2', t.UFix64),
  // ])
  // console.log(setRes3)

  // const setRes4 = await buildAndSendTrx('setRootDomainCommissionRate', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('0.3', t.UFix64),
  // ])
  // console.log(setRes4)
  // console.log('register domains with caos')
  // register
  // const result = await registerDomain(0, 'caosa','flow' '3153600.00000000', '5.00000000')
  // renew - at last
  // const renew = await renewDomain(0, namehash('depr4.flow'), '31536000.00000000', '0.10')
  // console.log(renew)
  // const flowNamehash = namehash('caos.flow')
  // const fnsNameHash = namehash('caos.fns')

  // const domains = await buildAndExecScript('queryRootDomains')

  // console.log(domains)

  // const id = await buildAndExecScript('queryDomaimId', [
  //   fcl.arg(namehash('testthedomainnameadd2.flow'), t.String),
  // ])
  // console.log(id)
  // const addr = await buildAndExecScript('queryDomainRecord', [
  //   fcl.arg(namehash('testthedomainnameadd2.flow'), t.String),
  // ])
  // console.log(addr, test1Addr)

  // const res = await buildAndExecScript('queryRootDomainVaultBalance', [fcl.arg(0, t.UInt64)])
  // console.log(res)

  // const vault = await buildAndSendTrx('withdrawRootVault', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(res, t.UFix64),
  // ])
  // console.log(vault)

  // const flowDetail = await buildAndExecScript('queryDomainInfo', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  // ])
  // console.log(flowDetail)

  // const name = namehash('sciencedirect.nft')
  // const fnsDetail = await buildAndExecScript('queryDomainInfo', [fcl.arg(name, t.String)])
  // console.log(fnsDetail)
  // const init = await buildSetupTrx('initDomainCollection', [])
  // console.log(init)
  // await buildSetupTrx('initDomainCollection', [], test2Authz())

  // const transferRes = await buildAndSendTrx('transferDomainWithId', [
  //   fcl.arg(100, t.UInt64),
  //   fcl.arg(test1Addr, t.Address),
  // ])
  // console.log(transferRes)
  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [
  //   fcl.arg('0x0c3881df196c01c9', t.Address),
  // ])
  // const userDomain = await buildAndExecScript('queryDomainInfo', [fcl.arg(namehash('depr.flow'), t.String)])

  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [
  //   fcl.arg('0x3c09a556ecca42dc', t.Address),
  // ])
  // console.dir(userDomain)

  // const deprId = await buildAndExecScript('queryDomaimId', [
  //   fcl.arg(namehash('depr2.flow'), t.String),
  // ])
  // console.dir(deprId)
  // const depr1Id = await buildAndExecScript('queryDomaimId', [
  //   fcl.arg(namehash('depr3.flow'), t.String),
  // ])
  // console.dir(depr1Id)

  // const deprInfo = await buildAndExecScript('queryDomainDeprecated', [
  //   fcl.arg(namehash('depr2.flow'), t.String),
  // ])
  // console.dir(deprInfo)

  // const depr1Info = await buildAndExecScript('queryDomainDeprecated', [
  //   fcl.arg(namehash('depr3.flow'), t.String),
  // ])
  // console.dir(depr1Info)

  // console.log(namehash('depr.flow'))

  // const res = await buildAndExecScript('queryIsDeprecated', [fcl.arg(namehash('depr.flow'), t.String), fcl.arg(14, t.UInt64)])
  // console.log(res)

  // const transferRes = await buildAndSendTrx(
  //   'transferDomainWithHashName',
  //   [fcl.arg(namehash('depr.flow'), t.String), fcl.arg(accountAddr, t.Address)],
  //   test1Authz(),
  // )
  // console.log(transferRes)

  // const withdraw = await buildAndSendTrx('withdrawVaultWithVaultType', [
  //   fcl.arg(namehash('caos.nft'), t.String),
  //   fcl.arg(flowVaultType, t.String),
  //   fcl.arg('8.0', t.UFix64),
  // ])

  // console.log(withdraw)
  // const test1Bal = await buildAndExecScript('queryFlowTokenBalance', [
  //   fcl.arg('0x0ce7a444df0a142b', t.Address),
  // ])
  // console.log(test1Bal)

  // const res1 = await buildAndSendTrx('renewDomain', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg(namehash('depr2.flow'), t.String),
  //   fcl.arg('31536000.00', t.UFix64),
  //   fcl.arg('4.8', t.UFix64),
  // ])
  // console.log(res1)

  // const ress = await buildAndSendTrx(
  //   'registerDomainBatch',
  //   [
  //     fcl.arg(0, t.UInt64),
  //     fcl.arg(['depr3'], t.Array(t.String)),
  //     fcl.arg('31536000.00', t.UFix64),
  //     fcl.arg(['4.74'], t.Array(t.UFix64)),
  //     fcl.arg(accountAddr, t.Address),
  //   ],
  //   test2Authz(),
  // )
  // console.log(ress, '=====')

  // const res = await buildAndExecScript('queryDomainAvailableBatch', [
  //   fcl.arg('0xefb7a4262551cd31d13b61b814a5dc591766fdb2be1ab2df33c26700c4702c16', t.String),
  //   fcl.arg(['f你💖', 'gfdgdsgfgga'], t.Array(t.String)),
  // ])
  // console.log(res)

  // const res = await buildAndSendTrx('depositDomainVaultWithFlow', [
  //   fcl.arg(namehash('caos.flow'), t.String),
  //   fcl.arg('1.0', t.UFix64),
  // ])
  // console.log(res)
  // const res1 = await buildAndSendTrx('depositDomainVaultWithFlow', [
  //   fcl.arg(namehash('caos.test'), t.String),
  //   fcl.arg('0.01', t.UFix64),
  // ])
  // console.log(res1)
  // const normName = normalize('你好.flow')
  // console.log(normName)
  // console.log(namehash(normName), 'norm---')
  // console.log(namehash('你好.flow'))

  // const hash = await buildAndExecScript('getDomainNameHash', [
  //   fcl.arg('你好', t.String),
  //   fcl.arg(namehash('flow'), t.String),
  // ])
  // console.log(hash, 'onchain')
  // const sendRes = await buildAndSendTrx('sendNFTToDomain', [
  //   fcl.arg(namehash('caos.flow'), t.String),
  //   fcl.arg(9, t.UInt64),
  // ])
  // console.log(sendRes)

  // const sendRes = await buildAndSendTrx(
  //   'withdrawNFTFromDomain',
  //   [
  //     fcl.arg(namehash('caos.flow'), t.String),
  //     fcl.arg(collectionType, t.String),
  //     fcl.arg(9, t.UInt64),
  //   ],
  // )
  // console.log(sendRes)

  // const withdraw = await buildAndSendTrx(
  //   'withdrawVaultWithVaultType',
  //   [
  //     fcl.arg(namehash('testthedomainname.flow'), t.String),
  //     fcl.arg(flowVaultType, t.String),
  //     fcl.arg('0.1', t.UFix64),
  //   ],
  //   test1Authz(),
  // )
  // console.log(withdraw)

  // const mintRes = await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  //   fcl.arg('test', t.String),
  // ])
  // console.log(mintRes)

  // const removeSub = await buildAndSendTrx('removeSubdomain', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  //   fcl.arg(namehash('test.depr4.flow'), t.String),
  // ])
  // console.log(removeSub)
  // console.log(namehash('test.depr4.flow'))
  // console.log(namehash('dev.depr4.flow'))
  // console.log(namehash('blog.depr4.flow'))

  // const subdomains = await buildAndExecScript('queryUsersAllSubDomain', [
  //   fcl.arg(accountAddr, t.Address),
  //   fcl.arg(namehash('depr4.flow'), t.String),
  // ])

  // console.log(subdomains)

  // const expired = await buildAndExecScript('queryDomainExpired', [
  //   fcl.arg(namehash('depr.flow'), t.String),
  // ])
  // console.log(expired)

  // const expiredTime = await buildAndExecScript('queryDomainExpiredTime', [
  //   fcl.arg(namehash('depr.flow'), t.String),
  // ])
  // console.log(expiredTime)

  // const allRes = await buildAndExecScript('getAllDomainRecords', [ ])
  // console.log(allRes)

  // const trxs = await buildAndSendTrx('mintDomainTo', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('soul', t.String),
  //   fcl.arg(oneYear.toFixed(2), t.UFix64),
  //   fcl.arg('0x8eb852196cb42b75', t.Address),
  // ])

  // console.log(trxs)

  // console.log(namehash('flow'))
  // const ava = await buildAndExecScript('queryDomainAvailable', [
  //   fcl.arg(namehash('f你💖.flow'), t.String),
  // ])
  // console.log(ava)
  // const mintRes1 = await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(namehash('depr3.flow'), t.String),
  //   fcl.arg('dev', t.String),
  // ])
  // console.log(mintRes1)

  // const mintRes2 = await buildAndSendTrx('mintSubdomain', [
  //   fcl.arg(namehash('depr3.flow'), t.String),
  //   fcl.arg('block', t.String),
  // ])
  // console.log(mintRes2)
  // const setRes = await buildAndSendTrx("setDomainForbidChars", [
  //   fcl.arg("!@$%^&*#()<>? ./ABCDEFGHIJKLMNOPQRSTUVWXYZ-", t.String),
  // ]);
  // console.log(setRes);

  // const trxs1 = await buildAndSendTrx('mintDomain', [
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('raven-kus', t.String),
  //   fcl.arg(oneYear.toFixed(2), t.UFix64),
  // ])

  // console.log(trxs1)

  // const setAddressRes = await buildAndSendTrx('setDomainAddress', [
  //   fcl.arg(namehash('caos.flow'), t.String),
  //   fcl.arg(0, t.UInt64),
  //   fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
  // ])
  // console.log(setAddressRes)

  // const setSubText = await buildAndSendTrx('setSubdomainText', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  //   fcl.arg(namehash('blog.depr4.flow'), t.String),
  //   fcl.arg('subText1', t.String),
  //   fcl.arg('subValue', t.String),
  // ])
  // console.log(setSubText)

  // const setSubText = await buildAndSendTrx('removeSubdomainAddress', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  //   fcl.arg(namehash('blog.depr4.flow'), t.String),
  //   fcl.arg(1, t.UInt64),
  // ])
  // console.log(setSubText)

  // const setSubAddr = await buildAndSendTrx('setSubdomainAddress', [
  //   fcl.arg(namehash('depr4.flow'), t.String),
  //   fcl.arg(namehash('blog.depr4.flow'), t.String),
  //   fcl.arg(3, t.UInt64),
  //   fcl.arg('0xCea5E66bec5193e5eC0b049a3Fe5d7Dd896fD480', t.String),
  // ])
  // console.log(setSubAddr)

  // const change = await buildAndSendTrx('changeRootDomainVaultWithFlow', [fcl.arg(0, t.UInt64)])
  // console.log(change)
  // const test = normalize('你好1.flow')
  // console.log(test)

  // console.log(namehash('te-st.fn'))
  // const hash = await buildAndExecScript('calcHashRaw', [
  //   fcl.arg('cosine', t.String),
  //   fcl.arg('fn', t.String),
  // ])
  // console.log(hash)

  // const queryHash = namehash('switchtest1.meow')
  // const flowDetail = await buildAndExecScript('queryDomainInfo', [fcl.arg(queryHash, t.String)])
  // console.log(flowDetail)

  // const record = await buildAndExecScript('queryDomainRecord', [fcl.arg(queryHash, t.String)])

  // console.log(record)

  // const domains = await buildAndExecScript('queryRootDomains')

  // console.log(domains)

  // const ress = await buildAndSendTrx(
  //   'registerDomainBatch',
  //   [
  //     fcl.arg(1, t.UInt64),
  //     fcl.arg(['cosine', 'caosbad'], t.Array(t.String)),
  //     fcl.arg('31536000.00', t.UFix64),
  //     fcl.arg(['5.74', '6.0'], t.Array(t.UFix64)),
  //     fcl.arg(test2Addr, t.Address),
  //   ],
  //   test2Authz(),
  // )
  // console.log(ress, '=====')

  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [
  //   fcl.arg(accountAddr, t.Address),
  // ])
  // console.dir(userDomain)

  // const hash = await buildAndExecScript('calcDomainNameHashLocal', [
  //   fcl.arg('caos', t.String),
  //   fcl.arg('fn', t.String),
  // ])
  // console.dir(hash)

  // const address = await buildAndExecScript('queryDomainRecordWithRaw', [
  //   fcl.arg('caosbad', t.String),
  //   fcl.arg('fn', t.String),
  // ])
  // console.dir(address)

  // const checkRes = await buildAndExecScript('checkDomainCollection', [
  //   fcl.arg('0x3c09a556ecca42dc', t.Address),
  // ])

  // console.log(checkRes)

  // const transferRes = await buildAndSendTrx('transferDomainWithId', [
  //   fcl.arg(2, t.UInt64),
  //   fcl.arg('0x1df8d0f0f3ae2b07', t.Address),
  // ])
  // //
  // console.log(transferRes)

  // const hash = namehash('caosbad.fn'.toLocaleLowerCase())
  // console.log(hash)
  // // // const setAddressRes = await buildAndSendTrx(
  // //   'setDomainAddress',
  // //   [
  // //     fcl.arg(namehash('depr.flow'), t.String),
  // //     fcl.arg(1, t.UInt64),
  // //     fcl.arg('0x3c09a556ecca42dc', t.String),
  // //   ],
  // //   test2Authz(),
  // // )

  // const id = await buildAndExecScript('queryDomaimId', [fcl.arg(hash, t.String)])
  // console.log(id)
  // // console.log(cosineHash)
  // // console.log(setAddressRes)

  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [
  //   fcl.arg('0xd5dab99b4e7301ce', t.Address),
  // ])
  // console.dir(userDomain)

  // const hash = namehash("raven-kus.fn".toLocaleLowerCase());
  // console.log(hash);

  // const flowDetail = await buildAndExecScript("queryDomainInfo", [
  //   fcl.arg(hash, t.String),
  // ]);
  // console.log(flowDetail);

  // const testRes = await buildAndExecScript('test', [fcl.arg('0xc0597793abff95ba', t.Address)])
  // console.log(testRes)

  // mint lilico
  // const mintRes = await buildAndSendTrx('mintLilico', [
  //   fcl.arg('lilico', t.String),
  //   fcl.arg(test2Addr, t.Address),
  // ])
  // console.log(mintRes)

  // console.log(await buildAndExecScript('queryUsersAllDomain', [fcl.arg(test1Addr, t.Address)]))
  console.log(
    await buildAndExecScript("queryUsersAllDomain", [
      fcl.arg('0x7179def56a8b9c5e', t.Address),
    ])
  );

  // const res = await query('https://www.flowns.org/api/data/address/0x95c1afc355056c36')
  // console.log(res.data)

  // batch renew

  // const renewRes = await await buildAndSendTrx('batchRenewWithHash', [
  //   fcl.arg(
  //     [namehash('tes1.flow'), namehash('thisisolen10.flow'), namehash('thisisolen2.flow')],
  //     t.Array(t.String),
  //   ),
  //   fcl.arg(oneYear.toFixed(2), t.UFix64),
  //   // fcl.arg('10.0', t.UFix64),
  //   fcl.arg(accountAddr, t.Address),
  // ])
  // console.log(renewRes)

  // const userDomain = await buildAndExecScript('queryUsersAllDomain', [
  //   fcl.arg(test1Addr, t.Address),
  // ])
  // console.dir(userDomain)

  // const batchRes = await buildAndSendTrx('transferFlowBatch', [
  //   fcl.arg(
  //     [
  //       '0xe14ec858612c27fb',
  //       '0x4a04ff8fabe85fd9',
  //       '0xb96e3003eeb1f9ac',
  //       '0x645ef7aa7a7291fd',
  //       '0x53f29ea4b01498f7',
  //       '0xa2067e038f0f7152',
  //       '0x6c031631a606532d',
  //       '0x4ad3bf3a4791d2b0',
  //       '0xa886b070d087e674',
  //       '0x6eef0fc267031951',
  //       '0x645ef7aa7a7291fd',
  //       '0x6761a501384744ad',
  //       '0xc57db8fe8c60f21b',
  //       '0x97e894ffc656c2dd',
  //       '0x79b09df771cbb8eb',
  //     ],
  //     t.Array(t.Address),
  //   ),
  //   fcl.arg('0.32', t.UFix64),
  // ])
  // //
  // console.log(batchRes)
  let metadata = await buildAndExecScript("getDomainMetadata", [
    fcl.arg('0x3c09a556ecca42dc', t.Address),
    fcl.arg(23370, t.UInt64),
  ]);

  console.log(metadata);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
