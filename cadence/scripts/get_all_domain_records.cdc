import Domains from 0xDomains

pub fun main() : { String: Address } {
    return Domains.getAllRecords()
}
