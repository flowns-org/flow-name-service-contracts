import Flowns from 0xFlowns

transaction(key: String, flag: Bool) {
  let client: &Flowns.Admin
  prepare(account: AuthAccount) {
      self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.updateFTWhitelist(key: key, flag: flag)
  }
}