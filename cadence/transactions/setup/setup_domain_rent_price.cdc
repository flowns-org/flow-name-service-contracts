import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(id: UInt64, len: Int, price: UFix64) {
  let client: &Flowns.Admin
  prepare(account:  auth(Storage, BorrowValue)  &Account) {
    self.client = account.storage.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) 
  }
  execute {
    self.client.setRentPrice(domainId: id, len: len, price: price)
  }
}