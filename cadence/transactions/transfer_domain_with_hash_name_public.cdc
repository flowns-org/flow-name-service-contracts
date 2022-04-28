import Flowns from 0xFlowns
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken

transaction(nameHash: String, receiver: Address) {
  var senderCollection: &Domains.Collection
  var receiverCollection: &{Domains.CollectionPublic}
  var domainId: UInt64
  prepare(account: AuthAccount) {
    self.senderCollection = account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath)!
    let receiverCollectionCap = getAccount(receiver).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 

    self.receiverCollection = receiverCollectionCap.borrow()?? panic("Canot borrow receiver's collection")

    var domainId: UInt64? = nil
    
    let id = Domains.getDomainId(nameHash)

    self.domainId = id!
  }
  execute {
    self.receiverCollection.deposit(token: <- self.senderCollection.withdraw(withdrawID: self.domainId))
  }
}
