import Domains from 0xDomains

pub fun main(address: Address) : Bool {
    return getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath).check()
}
 
 
 
