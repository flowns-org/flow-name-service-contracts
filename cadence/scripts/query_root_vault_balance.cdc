
import Flowns from 0xFlowns

access(all) fun main(id: UInt64): UFix64 {
  let balance = Flowns.getRootVaultBalance(domainId: id)
  return balance
}
