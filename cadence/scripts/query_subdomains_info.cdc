import Domains from 0xDomains

pub fun main(address: Address, nameHash: String): [Domains.SubdomainDetail] {
  let account = getAccount(address)
  let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  let collection = collectionCap.borrow()!
  let ids = collection.getIDs()
  var details:[Domains.SubdomainDetail]  = []
  for id in ids {
    let domain = collection.borrowDomain(id: id)
    if domain.nameHash == nameHash && !Domains.isDeprecated(nameHash:nameHash, domainId: id) {
      let subdomainDetail = domain.getSubdomainsDetail()
      details = subdomainDetail
    }
  }

  return details
}
