import Domains from 0xDomains

pub fun main(nameHash: String): Address? {
    var address = Domains.getRecords(nameHash)
    return address
}
