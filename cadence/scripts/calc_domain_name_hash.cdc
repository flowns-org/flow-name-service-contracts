
import Crypto

/*
  This script will check an address and print out its FT, NFT and Versus resources
 */

pub fun main(name:String) : String {
  let nameUFT8Arr = name.utf8
  
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