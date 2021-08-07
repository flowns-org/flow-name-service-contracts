
import Crypto

/*
  This script will check an address and print out its FT, NFT and Versus resources
 */

pub fun main() : [UInt8] {
   var domainName = ""
   let flowers = "Flowers \u{1F490}"
    let bytes = flowers.utf8
    log(bytes)
    let digest = Crypto.hash(bytes, algorithm: HashAlgorithms.SHA3_256)
  
  return digest
}