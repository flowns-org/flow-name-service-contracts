import Flowns from 0xFlowns
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken

transaction(nameHash: String, receiver: Address) {
  var senderCollection: &Domains.Collection
  var receiverCollection: &{NonFungibleToken.Receiver}
  var domainId: UInt64
  prepare(account: AuthAccount) {
    self.senderCollection = account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath)!
    let receiverCollectionCap = getAccount(receiver).getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    self.receiverCollection = receiverCollectionCap.borrow()?? panic("Canot borrow receiver's collection")

    
    let ids = self.senderCollection.getIDs()

    for id in ids {
      var item = self.senderCollection.borrowDomain(id: id)!
      if item.nameHash == nameHash && !Domains.isDeprecated(nameHash: nameHash, domainId: id) {
        self.domainId = id
      } 
    }
  }
  execute {
    self.receiverCollection.deposit(token: <- self.senderCollection.withdraw(withdrawID: self.domainId))
  }
}
