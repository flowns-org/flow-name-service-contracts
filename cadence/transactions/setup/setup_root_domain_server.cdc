import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(ownerAddress: Address, id:UInt64) {
    prepare(account: AuthAccount) {
        let owner= getAccount(ownerAddress)
        let client= owner.getCapability<&{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath)
                .borrow() ?? panic("Could not borrow admin client")
        //let cap = account.getCapability<&Domains.Collection>(Domains.CollectionPublicPath)!
        let cap = owner.getCapability<&Domains.Collection>(Domains.CollectionPublicPath)
        client.addRootDomainCapability(domainId:id, cap:cap)
        log("Root domain server cap inited...")
    }

}
