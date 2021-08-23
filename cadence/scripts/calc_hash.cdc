import Flowns from 0xFlowns

pub fun main(node: String, lable: String) : String {
    // let prefix = "0x"
    // return prefix.concat(Flowns.hash(node: node, lable: lable))
    let hash = "0x6f6ae59d6f61aafa520e9f179f292bf6cd66f189d556896ae962057ef1b9fda7"
    let ha = hash.slice(from: 2, upTo: 66)
      let nameSha = String.encodeHex(HashAlgorithm.SHA3_256.hash(lable.utf8))
      let nameHash = "0x".concat(String.encodeHex(HashAlgorithm.SHA3_256.hash(ha.concat(nameSha).utf8)))
    return nameHash
}
