import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(domainNameHash:String, key:String, value: String) {
  var domain: &{Domains.DomainPrivate}
  prepare(account: AuthAccount) {
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = collection.getIDs()

    for id in ids {
      var item = collection.borrowDomain(id:id)
      if item.nameHash == domainNameHash {
        domain = collectionPrivate.borrowDomainPrivate(id)
      } 
    }
    self.domain = domain!
  }
  execute {
    self.domain.setText(key:key, value:value)
  }
}
