import Flowns from 0xFlowns

pub fun main(name: String, root: String) : String {
  let prefix = "0x"
  let rootHahsh = Flowns.hash(node: "", lable: root)
  return prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
}
