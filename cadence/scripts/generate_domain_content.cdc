import Domains from 0xDomains

pub fun main(nameHash: String): [Domains.DomainDetail] {
  let address = Domains.records[nameHash]!
  let account = getAccount(address)
  let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  let collection = collectionCap.borrow()!
  let domain: Domains.DomainDetail? = nill
  let ids = collection.getIDs()
  
  for id in ids {
    let domain = collection.borrowDomain(id:id)
    if domain.nameHash == nameHash {
      domain = domain.getDetail()
    }

  }

  return domains
}
