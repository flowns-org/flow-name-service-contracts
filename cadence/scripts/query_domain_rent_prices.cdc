import Flowns from 0xFlowns

pub fun main() : { UInt64: Flowns.RootDomainInfo }? {
    return Flowns.getAllRootDomains()
}
