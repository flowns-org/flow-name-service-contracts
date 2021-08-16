import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(domainNameHash: String, subdomainNameHash: String, chainType: UInt64, address: String) {
  var domain: &{Domains.DomainPrivate}
  prepare(account: AuthAccount) {
    var domainRef: &{Domains.DomainPrivate}? = nil
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = collection.getIDs()

    for id in ids {
      let item = collection.borrowDomain(id: id)
      if item.nameHash == domainNameHash && !Domains.isDeprecated(nameHash:domainNameHash, domainId: id) {
        domainRef = collectionPrivate.borrowDomainPrivate(id)
      } 
    }
    self.domain = domainRef!
  }
  execute {
    self.domain.setSubdomainAddress(nameHash: subdomainNameHash, chainType: chainType, address: address)
  }
}
