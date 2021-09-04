
import Domains from 0xDomains

pub fun main(nameHash: String, id: UInt64): Bool {
  return Domains.isDeprecated(nameHash: nameHash, domainId: id)
}
