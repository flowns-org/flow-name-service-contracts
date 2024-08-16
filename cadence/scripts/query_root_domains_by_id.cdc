
import Flowns from 0xFlowns

access(all) fun main(id: UInt64): Flowns.RootDomainInfo? {
    return Flowns.getRootDomainInfo(domainId: id)
}
