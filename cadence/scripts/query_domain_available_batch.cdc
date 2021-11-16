
import Flowns from 0xFlowns

pub fun main(nameHashs: [String]) : [Bool] {
  var idx = 0
  var results: [Bool] = []
  while idx < nameHashs.length {
    var available = Flowns.available(nameHash: nameHashs[idx]) 
    results.append(available)
    idx = idx + 1
  }
  return results
}
