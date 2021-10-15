import Domains from 0xDomains

pub fun main(nameHash: String): Domains.DomainDetail? {
  let address = Domains.getRecords(nameHash) ?? panic("Domain not exist")
  let account = getAccount(address)
  let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  let collection = collectionCap.borrow()!
  var detail: Domains.DomainDetail? = nil
  // let ids = collection.getIDs()
  
  // for id in ids {
  //   let domain = collection.borrowDomain(id: id)
  //   if domain.nameHash == nameHash && !Domains.isDeprecated(nameHash:nameHash, domainId: id) {
  //     detail = domain.getDetail()
  //   }
  // }
  let id = Domains.getDomainId(nameHash)
  if id != nil && !Domains.isDeprecated(nameHash: nameHash, domainId: id!) {
    let domain = collection.borrowDomain(id: id!)
    detail = domain.getDetail()
  }

  return detail
}
