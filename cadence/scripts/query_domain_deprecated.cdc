
import Domains from 0xDomains

pub fun main(nameHash: String): {UInt64: Domains.DomainDeprecatedInfo}? {
  return Domains.getDeprecatedRecords(nameHash)
}
