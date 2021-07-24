import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(domainNameHash:String, subdomainNameHash:String, key:String, value: String) {
  var domain: &{Domains.DomainPrivate}
  prepare(account: AuthAccount) {
    var domainRef:&{Domains.DomainPrivate}? = nil
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

    let ids = collection.getIDs()

    for id in ids {
      let domain = collection.borrowDomain(id:id)
      if domain!.nameHash == domainNameHash {
       domainRef = collectionPrivate.borrowDomainPrivate(id)
      }
    }
    // self.domain = &item!.subdomains[subdomainNameHash] as! auth &{Domains.SubdomainPrivate}
    self.domain = domainRef!
  }
  execute {
    self.domain.setSubdomainText(nameHash:subdomainNameHash, key:key, value:value)
  }
}
