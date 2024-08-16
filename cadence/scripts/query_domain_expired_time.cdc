import Domains from 0xDomains

access(all) fun main(nameHash: String): UFix64? {
    return Domains.getExpiredTime(nameHash)
}
