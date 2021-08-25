import Domains from 0xDomains

pub fun main() : { String: {UInt64: Domains.DomainDeprecatedInfo} } {
    return Domains.getAllDeprecatedRecords()
}
