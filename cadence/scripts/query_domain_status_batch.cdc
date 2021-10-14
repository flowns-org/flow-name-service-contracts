
import Crypto
import Flowns from 0xFlowns

pub fun main(rootName: String, names: [String]) : [Bool] {

  var idx = 0
  var results: [Bool] = []
  while idx < names.length {
    var nameHash = hash(name: names[idx], parentName: rootName)
    var available = Flowns.available(nameHash: nameHash) 
    results.append(available)
    idx = idx + 1
  }
  return results
}

pub fun hash(name: String, parentName: String) : String {
  let prefix = "0x"
  let emptyNode = "0000000000000000000000000000000000000000000000000000000000000000"
  let nameBytes = name.utf8
  // validate
  let parentNameBates = parentName.utf8
  let parantNameHash = Crypto.hash(parentNameBates, algorithm: HashAlgorithm.SHA3_256)
  let appendName = prefix.concat(name).concat(String.encodeHex(parantNameHash))
  
  let domainHash = Crypto.hash(appendName.utf8, algorithm: HashAlgorithm.SHA3_256)
  let test = HashAlgorithm.SHA3_256.hash(name.utf8)
  let res = emptyNode.concat(String.encodeHex(test))
  let hash = HashAlgorithm.SHA3_256.hash(res.utf8)
  return prefix.concat(String.encodeHex(hash))
}