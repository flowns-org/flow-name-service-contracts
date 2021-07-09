
//testnet
//import FungibleToken from 0xf233dcee88fe0abe
//import NonFungibleToken from 0x1d7e57aa55817448
//import Art from 0x1ff7e32d71183db0

// emulator

import Flowns from 0xf8d6e0586b0a20c7

// import Flowns from 0x05

/*
  This script will check an address and print out its an flowns admin
 */
pub fun main(id: UInt64) : { UInt64: Flowns.RootDomainInfo }? {
    return Flowns.getRootDomainInfo(domainId: id)
}
