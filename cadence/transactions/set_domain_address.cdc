import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(domainNameHash: String, chainType: UInt64, address: String) {
  var domain: &{Domains.DomainPrivate}
  prepare(account: AuthAccount) {
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

    let id = Domains.getDomainId(domainNameHash)
    if id != nil && !Domains.isDeprecated(nameHash: domainNameHash, domainId: id!) {
      domain = collectionPrivate.borrowDomainPrivate(id!)
    }
    self.domain = domain!
  }
  execute {
    self.domain.setAddress(chainType: chainType, address: address)
  }
}

