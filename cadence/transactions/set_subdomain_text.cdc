import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(domainNameHash: String, subdomainNameHash: String, key: String, value: String) {
  var domain: &{Domains.DomainPrivate}
  prepare(account: AuthAccount) {
    var domainRef:&{Domains.DomainPrivate}? = nil
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

    let id = Domains.getDomainId(domainNameHash)
    if id != nil && !Domains.isDeprecated(nameHash: domainNameHash, domainId: id!) {
      domainRef = collectionPrivate.borrowDomainPrivate(id!)
    }
    self.domain = domainRef!
  }
  execute {
    self.domain.setSubdomainText(nameHash: subdomainNameHash, key: key, value: value)
  }
}
