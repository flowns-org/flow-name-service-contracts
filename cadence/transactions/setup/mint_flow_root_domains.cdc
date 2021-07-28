import Flowns from 0xFlowns
import FlowToken from 0xFlowToken
import FungibleToken from 0xFungibleToken

transaction() {
  let client: &Flowns.Admin
  let vault: @FungibleToken.Vault
  prepare(account: AuthAccount) {
      self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
      self.vault <- FlowToken.createEmptyVault()
  }
  execute {
    self.client.createRootDomain(name: "flow", nameHash: "0x9f1a2c1ae3169a570d1045fe9fc6cb93e68bcc86c545e8dda83ee4aeda090469", vault: <- self.vault)
  }
}
