import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken



transaction(nameHash: String, itemId: UInt64) {
  var domain: &{Domains.DomainPublic}
  var collection: @NonFungibleToken.Collection
  var NFT: @NonFungibleToken.NFT
  let sender: Address
  prepare(account: AuthAccount) {
    let address = Domains.getRecords(nameHash) ?? panic("Can not find domain ..")
    let userCollection = getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath).borrow()! 

    var domain: &{Domains.DomainPublic}? = nil

    let ids = userCollection.getIDs()
    for id in ids {
      var item = userCollection.borrowDomain(id: id)
      if item.nameHash == nameHash && !Domains.isDeprecated(nameHash: nameHash, domainId: id) {
        domain = item
      } 
    }
    self.domain = domain!
    let senderCollection = account.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath)!
    self.sender = senderCollection.owner!.address
    self.NFT <- senderCollection.withdraw(withdrawID: itemId)
    self.collection <- Domains.createEmptyCollection()

  }
  execute {
    let typeKey = self.collection.getType().identifier

    if self.domain!.checkCollection(key: typeKey) == false {
      self.domain.addCollection(collection: <- self.collection )
    } 
    self.domain!.depositNFT(key: typeKey, token: <- self.NFT, sender: self.sender)
  }
}
