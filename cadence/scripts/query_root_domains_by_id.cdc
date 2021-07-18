
import Flowns from 0xFlowns

pub fun main(id: UInt64): Flowns.RootDomainInfo? {
    return Flowns.getRootDomainInfo(domainId: id)
}
