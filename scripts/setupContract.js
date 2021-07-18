import t from '@onflow/types'
import { fclInit, readCode, sendTrx } from '../utils/index.js'
import { paths } from '../config/constants.js'

const main = async () => {
  // fcl init
  const { setup } = paths
  fclInit()
  const initDomainCollectionCode = await readCode(setup['initDomainCollection'])
  const args = []
  const trxId = await sendTrx(initDomainCollectionCode, args)
  console.log(trxId)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
