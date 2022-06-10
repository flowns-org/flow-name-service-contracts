import FungibleToken from 0xFungibleToken
import Domains from 0xFlowns
import <Token> from <TokenAddress>

transaction(amount: UFix64, recipient: Address) {

  // The Vault resource that holds the tokens that are being transfered
  let senderRef: &{FungibleToken.Receiver}
  let sentVault: @FungibleToken.Vault
  let sender: Address

  prepare(signer: AuthAccount) {
    // Get a reference to the signer's stored vault
    let vaultRef = signer.borrow<&<Token>.Vault>(from: <Token>.VaultStoragePath)
      ?? panic("Could not borrow reference to the owner's Vault!")
    self.senderRef = signer.getCapability(<Token>.ReceiverPublicPath)
      .borrow<&{FungibleToken.Receiver}>()!
    self.sender = vaultRef.owner!.address
    // Withdraw tokens from the signer's stored vault
    self.sentVault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    // Get the recipient's public account object
    let recipientAccount = getAccount(recipient)

    // Get a reference to the recipient's Receiver
    let receiverRef = recipientAccount.getCapability(<Token>.ReceiverPublicPath)
      .borrow<&{FungibleToken.Receiver}>()
    
    if receiverRef == nil {
        let collectionCap = recipientAccount.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
        let collection = collectionCap.borrow()!
        var defaultDomain: &{Domains.DomainPublic}? = nil

        let ids = collection.getIDs()

        if ids.length == 0 {
            panic("Recipient have no domain ")
        }
        
        defaultDomain = collection.borrowDomain(id: ids[0])!
            // check defualt domain 
        for id in ids {
          let domain = collection.borrowDomain(id: id)!
          let isDefault = domain.getText(key: "isDefault")
          if isDefault == "true" {
            defaultDomain = domain
          }
        }
        // Deposit the withdrawn tokens in the recipient's domain inbox
        defaultDomain!.depositVault(from: <- self.sentVault, senderRef: self.sentVault)

    } else {
        // Deposit the withdrawn tokens in the recipient's receiver
        receiverRef!.deposit(from: <- self.sentVault)
    }
  }
}