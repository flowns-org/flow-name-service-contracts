import Domains from 0xDomains

pub fun main(address: Address): [Domains.DomainDetail] {
  let account = getAccount(address)
  let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  let collection = collectionCap.borrow()!
  let domains:[Domains.DomainDetail] = []
  let ids = collection.getIDs()
  
  for id in ids {
    let domain = collection.borrowDomain(id: id)
    let detail = domain.getDetail()
    domains.append(detail)
  }

  return domains
}
