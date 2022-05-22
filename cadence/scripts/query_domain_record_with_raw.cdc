import Flowns from 0xFlowns
import Domains from 0xDomains

pub fun main(name: String, root: String) : Address? {
  let prefix = "0x"
  let rootHahsh = Flowns.hash(node: "", lable: root)
  let namehash = prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
  var address = Domains.getRecords(namehash)
  return address
}