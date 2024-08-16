import Domains from 0xDomains

pub fun main(address: Address) : Bool {
    return getAccount(address).capabilities.exists(Domains.CollectionPublicPath)
}
 
 
 
