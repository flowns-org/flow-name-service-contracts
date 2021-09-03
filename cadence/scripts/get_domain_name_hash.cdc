import Flowns from 0xFlowns

pub fun main(name: String, parentNameHash: String) : String {
  return Flowns.getDomainNameHash(name: name, parentNameHash: parentNameHash)
}
