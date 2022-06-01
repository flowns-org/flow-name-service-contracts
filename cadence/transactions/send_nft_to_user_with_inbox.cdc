import NonFungibleToken from 0xNonFungibleToken
import Domains from 0xDomains
import <NFT> from <NFTAddress>


// This transaction is for transferring and NFT from
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {

  prepare(signer: AuthAccount) {
    // get the recipients public account object
    let recipient = getAccount(recipient)

    // borrow a reference to the signer's NFT collection
    let collectionRef = signer
      .borrow<&NonFungibleToken.Collection>(from: <NFT>.CollectionStoragePath)
      ?? panic("Could not borrow a reference to the owner's collection")

    // borrow a public reference to the receivers collection
    let recipientRef = recipient
      .getCapability(<NFT>.CollectionPublicPath)
      .borrow<&{<NFT>.CollectionPublic}>()
    
		if recipientRef == nil {
			let collectionCap = recipient.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
			let collection = collectionCap.borrow()!
			var defaultDomain: &{Domains.DomainPublic}? = nil
    
      let ids = collection.getIDs()

			if ids.length == 0 {
				panic("Recipient have no domain ")
			}
			
		  // check defualt domain 
	    for id in ids {
	      let domain = collection.borrowDomain(id: id)!
	      let isDefault = domain.getText(key: "isDefault")
	      defaultDomain = domain
	      if isDefault == "true" {
	        break
	      }
	    }
      let typeKey = collectionCap.getType().identifier
      // withdraw the NFT from the owner's collection
      let nft <- collectionRef.withdraw(withdrawID: withdrawID)
      if defaultDomain!.checkCollection(key: typeKey) == false {
        let collection <- <NFT>.createEmptyCollection()
        collection.deposit(token: <- nft) 
        defaultDomain!.addCollection(collection: <- collection )
      } else {
        defaultDomain!.depositNFT(key: typeKey, token: <- collectionRef.withdraw(withdrawID: withdrawID))
      }
		} else {
			// withdraw the NFT from the owner's collection
      let nft <- collectionRef.withdraw(withdrawID: withdrawID)
      // Deposit the NFT in the recipient's collection
      recipientRef!.deposit(token: <-nft)
		}
  }
}