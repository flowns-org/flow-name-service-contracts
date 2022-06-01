import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(id: UInt64) {
    var client: &{Flowns.AdminPrivate}
    var cap: Capability<&Domains.Collection>
    prepare(account: AuthAccount) {
      self.client = account.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
      self.cap = account.getCapability<&Domains.Collection>(Domains.CollectionPrivatePath)
    }
    execute {
      self.client.addRootDomainCapability(domainId: id, cap: self.cap)
    }
}
