import Domains from 0xDomains

pub fun main(address: Address, nameHash: String): Domains.DomainDetail {
    let account= getAccount(address)
    let collectionCap: Capability<&{Domains.CollectionPublic}>= account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()
    
    let ids = collection.getIDs()

    return address
}
