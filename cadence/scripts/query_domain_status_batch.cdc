
import Crypto
import Flowns from 0xFlowns

pub fun main(rootNameHash: String, names: [String]) : [Bool] {

  var idx = 0
  var results: [Bool] = []
  while idx < names.length {
    var nameHash = Flowns.getDomainNameHash(name:names[idx], parentNameHash: rootNameHash )
    var available = Flowns.available(nameHash: nameHash) 
    results.append(available)
    idx = idx + 1
  }
  return results
}
