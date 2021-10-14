import Domains from 0xDomains

pub fun main(nameHash: String): UInt64? {
  var id = Domains.getDomainId(nameHash)
  return id
}
