import Flowns from 0xFlowns

pub fun main(domainId: UInt64, nameHash: String) : Bool {
    return Flowns.available(domainId: domainId, nameHash: nameHash )
}
