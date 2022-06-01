import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken
import <NFT> from <NFTAddress>


// key will be 'A.f8d6e0586b0a20c7.Domains.Collection' of a NFT collection
transaction(nameHash: String, key: String, itemId: UInt64) {
  var domain: &{Domains.DomainPrivate}
  var collectionRef: &Domains.Collection
  prepare(account: AuthAccount) {
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

    let id = Domains.getDomainId(nameHash)
    if id !=nil {
      domain = collectionPrivate.borrowDomainPrivate(id!)
    }
    self.domain = domain!

    let collectionRef = account.borrow<&<NFT>.Collection>(from: <NFT>.CollectionStoragePath)
    if collectionRef == nil {
      account.save<@NonFungibleToken.Collection>(<- <NFT>.createEmptyCollection(), to: <NFT>.CollectionStoragePath)
      account.link<&<NFT>.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, <NFT>.CollectionPublic}>(<NFT>.CollectionPublicPath, target: <NFT>.CollectionStoragePath)
      account.link<&<NFT>.Collection>(<NFT>.CollectionPrivatePath, target: <NFT>.CollectionStoragePath)

      self.collectionRef = account.borrow<&<NFT>.Collection>(from: <NFT>.CollectionStoragePath)?? panic("Can not borrow collection")
    } else {
      self.collectionRef = collectionRef!
    }
   
  }
  execute {
    self.collectionRef.deposit(token: <- self.domain.withdrawNFT(key: key, itemId: itemId))
  }
}
