
import Flowns from 0xFlowns

pub fun main(id: UInt64): UFix64 {

    let balance = Flowns.getRootVaultBalance(domainId: id)

    return balance
}
