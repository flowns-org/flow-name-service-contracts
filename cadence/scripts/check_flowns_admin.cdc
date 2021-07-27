import Flowns from 0xFlowns

pub fun main(address: Address) : Bool {

    let account = getAccount(address)
    let adminClient: Capability<&{Flowns.AdminPublic}> = account.getCapability<&{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath) 
    return adminClient.check()
}
