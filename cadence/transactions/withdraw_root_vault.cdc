import Flowns from 0xFlowns
import FungibleToken from 0xFungibleToken

transaction(domainId: UInt64, amount: UFix64) {
  let client: &Flowns.Admin
  let receiver: Capability<&{FungibleToken.Receiver}>
  prepare(account:  auth(Storage, BorrowValue)  &Account) {
    self.receiver = account.capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    self.client = account.storage.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) 
  }
  execute {
    self.client.withdrawVault(domainId: domainId, receiver: self.receiver, amount: amount)
  }
}
