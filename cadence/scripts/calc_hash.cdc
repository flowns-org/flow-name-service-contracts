import Flowns from 0xFlowns

pub fun main(node: String, lable: String) : String {
    let prefix = "0x"
    return prefix.concat(Flowns.hash(node: node, lable: lable))
}
