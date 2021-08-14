import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
// key will be 'A.f8d6e0586b0a20c7.Domains.Collection' of a NFT collection
transaction(nameHash: String, key: String, itemId: UInt64) {
  var domain: &{Domains.DomainPrivate}
  var collection: &Domains.Collection
  prepare(account: AuthAccount) {
    self.collection = account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath)?? panic("Can not borrow collection")
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = self.collection.getIDs()

    for id in ids {
      var item = self.collection.borrowDomain(id: id)
      if item.nameHash == nameHash {
        domain = collectionPrivate.borrowDomainPrivate(id)
      } 
    }
    self.domain = domain!
   
  }
  execute {
    self.collection.deposit(token: <- self.domain.withdrawNFT(key: key, itemId: itemId))
  }
}
