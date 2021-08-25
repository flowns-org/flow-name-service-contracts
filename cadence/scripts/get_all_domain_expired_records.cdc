import Domains from 0xDomains

pub fun main() : { String: UFix64 } {
    return Domains.getAllExpiredRecords()
}
