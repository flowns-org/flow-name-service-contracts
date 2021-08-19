import Flowns from 0xFlowns

pub fun main(address: Address) : Bool {

    let account = getAccount(address)
    let adminClient = account.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) 
    return adminClient != nil
}
