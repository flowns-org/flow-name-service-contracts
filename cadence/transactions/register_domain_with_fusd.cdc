import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(domainId: UInt64, name: String, nameHash: String, duration: UFix64, amount: UFix64) {
  let collectionCap: Capability<&{NonFungibleToken.Receiver}>
  let vault: @FungibleToken.Vault
  prepare(account: AuthAccount) {
    self.collectionCap = account.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/fusdVault)
          ?? panic("Could not borrow owner's Vault reference")
    self.vault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    Flowns.registerDomain(domainId: domainId, name: name, nameHash: nameHash, duration: duration, feeTokens: <- self.vault, receiver: self.collectionCap)
  }
}
