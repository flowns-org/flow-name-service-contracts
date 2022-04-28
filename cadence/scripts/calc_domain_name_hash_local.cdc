
import Crypto


pub fun main(name:String, parentName: String) : String {
  let prefix = "0x"

  let parentNameHash = hash(node: "", lable: parentName)

  let nameHash = hash(node:parentNameHash, lable:name )

  return prefix.concat(nameHash)
}

pub fun hash(node: String, lable: String): String {
  var prefixNode = node
  if node.length == 0 {
    prefixNode = "0000000000000000000000000000000000000000000000000000000000000000"
  }
  let lableHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(lable.utf8))
  let hash = String.encodeHex(HashAlgorithm.SHA3_256.hash(prefixNode.concat(lableHash).utf8))
  return hash
}