import Domains from 0xDomains

pub fun main(nameHash: String): Bool {
  return Domains.isExpired(nameHash)
}
