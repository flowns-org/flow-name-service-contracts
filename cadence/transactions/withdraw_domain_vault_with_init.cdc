import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import <Token> from <TokenAddress>

// key will be 'A.0ae53cb6e3f42a79.FlowToken.Vault' for flowtoken

transaction(nameHash: String, key: String, amount: UFix64) {
  var domain: &{Domains.DomainPrivate}
  var vaultRef: &<Token>.Vault
  prepare(account: AuthAccount) {
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = collection.getIDs()

    let id = Domains.getDomainId(nameHash)
    if id != nil && !Domains.isDeprecated(nameHash: nameHash, domainId: id!) {
      domain = collectionPrivate.borrowDomainPrivate(id!)
    }

    self.domain = domain!
    let vaultRef =  account.borrow<&<Token>.Vault>(from: <Token>.VaultStoragePath)
    if vaultRef == nil {
      account.save(<- <Token>.createEmptyVault(), to: <Token>.VaultStoragePath)

      account.link<&<Token>.Vault{FungibleToken.Receiver}>(
        <Token>.ReceiverPublicPath,
        target: <Token>.VaultStoragePath
      )

      account.link<&<Token>.Vault{FungibleToken.Balance}>(
        <Token>.BalancePublicPath,
        target: <Token>.VaultStoragePath
      )
      self.vaultRef = account.borrow<&<Token>.Vault>(from: <Token>.VaultStoragePath)
    ?? panic("Could not borrow reference to the owner's Vault!")

    } else {
      self.vaultRef = vaultRef!
    }
  }
  execute {
    self.vaultRef.deposit(from: <- self.domain.withdrawVault(key: key, amount: amount))
  }
}