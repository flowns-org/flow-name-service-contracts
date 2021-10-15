import Flowns from 0xFlowns
import FlowToken from 0xFlowToken
import FungibleToken from 0xFungibleToken

transaction(domainId:UInt64) {
  let client: &Flowns.Admin
  let vault: @FungibleToken.Vault
  prepare(account: AuthAccount) {
      self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
      self.vault <- FlowToken.createEmptyVault()
  }
  execute {
    self.client.changeRootDomainVault(domainId:domainId, vault: <- self.vault)
  }
}