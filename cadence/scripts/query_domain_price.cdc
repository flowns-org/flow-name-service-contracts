import Flowns from 0xFlowns

pub fun main(domainId: UInt64, name: String) : UFix64? {
  let root = Flowns.getRootDomainInfo(domainId: domainId)!
  let length = name.length
  return root.prices[length]
}
  