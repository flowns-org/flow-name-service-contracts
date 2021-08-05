import Flowns from 0xFlowns

transaction(flag: Bool) {
  let client: &Flowns.Admin
  prepare(account: AuthAccount) {
    self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.setPause(flag)
  }
}
