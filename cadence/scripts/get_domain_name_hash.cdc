import Flowns from 0xFlowns

pub fun main(name: String, parentName: String) : String {
    return Flowns.getDomainNameHash(name: name, parentName: parentName)
}
