
import Crypto


pub fun main(name:String, parentName: String) : String {
  let prefix = "0x"
  let emptyNode = "0000000000000000000000000000000000000000000000000000000000000000"

  let forbidenChars: [UInt8] = [33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 60, 62, 63, 32, 46]

  let nameASCII = name.utf8
  let parentNameASCII = parentName.utf8

  for char in nameASCII {
    if forbidenChars.contains(char) {
      panic("Domain name illegal...")
    }
  }
  for char in parentNameASCII {
    if forbidenChars.contains(char) {
      panic("Domain name illegal...")
    }
  }

  // let parentNameHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(emptyNode.concat(String.encodeHex(HashAlgorithm.SHA3_256.hash(parentNameASCII)))))
  let parentNameHash = hash(root: emptyNode, lable: parentName)
  let nameHash = hash(root:parentNameHash, lable:name )


  
  // let nameBytes = name.utf8
  // validate
  // let parentNameBates = parentName.utf8
  // let parantNameHash = Crypto.hash(parentNameBates, algorithm: HashAlgorithm.SHA3_256)
  // let appendName = prefix.concat(name).concat(String.encodeHex(parantNameHash))
  
  // let domainHash = Crypto.hash(appendName.utf8, algorithm: HashAlgorithm.SHA3_256)
  // let test = HashAlgorithm.SHA3_256.hash(name.utf8)
  // let res = emptyNode.concat(String.encodeHex(test))
  // let hash = HashAlgorithm.SHA3_256.hash(res.utf8)
  return prefix.concat(parentNameHash)

}

pub fun hash(root:String, lable: String): String {
  let lableHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(lable.utf8))
  let nodeHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(root.concat(lableHash).utf8))
  return nodeHash
}