import Flowns from 0xFlowns

access(all) fun main(domainId: UInt64) : { Int: UFix64 }? {
    return Flowns.getRentPrices(domainId: domainId)
}
