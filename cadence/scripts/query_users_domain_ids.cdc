import Domains from 0xDomains

pub fun main(address: Address): [Uint64] {
  let account = getAccount(address)
  let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  let collection = collectionCap.borrow()!
  let domains:[Domains.DomainDetail] = []
  let ids = collection.getIDs()
  
  return ids
}
