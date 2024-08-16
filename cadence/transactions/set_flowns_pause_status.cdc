import Flowns from 0xFlowns

transaction(flag: Bool) {
  let client: &{Flowns.AdminPrivate}
  prepare(account: auth(Storage, BorrowValue)  &Account) {
    self.client = account.storage.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) 
  }
  execute {
    self.client.setPause(flag)
  }
}
