// This script checks that the accounts are set up correctly for the marketplace tutorial.
// emulator
import Domains from 0xf8d6e0586b0a20c7


//testnet
//import FungibleToken from 0xf233dcee88fe0abe
//import NonFungibleToken from 0x1d7e57aa55817448
//import Art from 0x1ff7e32d71183db0


//mainnnet
// import FungibleToken from 0xf233dcee88fe0abe
// import NonFungibleToken from 0x1d7e57aa55817448


/*
  This script will check an address and print out its FT, NFT and Versus resources
 */
pub fun main(address:Address) : Bool {
    return getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath).check()
}
 
 
 
