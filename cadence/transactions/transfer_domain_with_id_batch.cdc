import Flowns from 0xFlowns
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken

transaction(itemIds: [UInt64], receiver: Address) {
  var senderCollection: &Domains.Collection
  var receiverCollection: &{NonFungibleToken.Receiver}
  prepare(account: AuthAccount) {
    self.senderCollection = account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath)!
    let receiverCollectionCap = getAccount(receiver).getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    self.receiverCollection = receiverCollectionCap.borrow()?? panic("Canot borrow receiver's collection")
  }
  execute {
    for id in itemIds {
      self.receiverCollection.deposit(token: <- self.senderCollection.withdraw(withdrawID: id))
    }
  }
}
