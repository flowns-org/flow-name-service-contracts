import Domains from 0xDomains

pub fun main(nameHash: String): Address? {
    var address = Domains.domainRecord(nameHash: nameHash)
    return address
}
