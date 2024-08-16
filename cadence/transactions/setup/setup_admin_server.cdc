import Flowns from 0xFlowns

transaction() {
    prepare(account: &Account) {
        let client = account.storage.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
        let rootDomainCap = account.capabilities.borrow<&Flowns.RootDomainCollection>(Flowns.CollectionPrivatePath)
        
        client.addCapability(rootDomainCap)
        log("Admin server cap inited...")
    }

}
 