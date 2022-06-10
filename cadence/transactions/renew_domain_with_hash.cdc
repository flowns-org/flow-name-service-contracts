import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(nameHash: String, duration: UFix64, amount: UFix64, refer: Address) {
  let vault: @FungibleToken.Vault
  prepare(account: AuthAccount) {
    
    let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner's Vault reference")
    
    self.vault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    Flowns.renewDomainWithNameHash(nameHash: nameHash, duration: duration, feeTokens: <- self.vault, refer: refer)
  }
}
 