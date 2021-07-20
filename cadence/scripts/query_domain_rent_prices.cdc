import Flowns from 0xFlowns

pub fun main(domainId: UInt64) : { Int:UFix64 }? {
    return Flowns.getRentPrices(domainId:domainId)
}
