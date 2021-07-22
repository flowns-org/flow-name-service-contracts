import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(domainNameHash:String, subdomainNameHash:String, key:String, value: String) {
  var subdomain: &Domains.Subdomain
  prepare(account: AuthAccount) {
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    let ids = collection.getIDs()
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    var subdomainRef:&Domains.Subdomain? = nil
    for id in ids {
      let domain = collection.borrowDomain(id:id)
      if domain!.nameHash == domainNameHash {
       subdomainRef = collectionPrivate.borrowSubDomainPrivate(id:id, nameHash:subdomainNameHash)
      }
    }
    // self.domain = &item!.subdomains[subdomainNameHash] as! auth &{Domains.SubdomainPrivate}
    self.subdomain = subdomainRef!
  }
  execute {
    self.subdomain.setText(key:key, value:value)
  }
}
