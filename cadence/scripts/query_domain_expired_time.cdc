import Domains from 0xDomains

pub fun main(nameHash: String): UFix64? {
    return Domains.getExpiredTime(nameHash)
}
