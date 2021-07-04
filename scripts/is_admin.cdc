
//testnet


//emulator
import Flowns from 0xf8d6e0586b0a20c7

// emulator
// import Flowns from 0x05
/*
  This script will check an address and print out its an flowns admin
 */
pub fun main(address:Address) : Bool {

    let account=getAccount(address)
    let adminClient: Capability<&{Flowns.AdminPublic}> =account.getCapability<&{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath) 
    return adminClient.check()
}
