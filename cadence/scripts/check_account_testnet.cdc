
import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import Content, Art, Auction, Versus from  0xd796ff17107bbff6

pub struct AddressStatus {

  pub(set) var address:Address
  pub(set) var balance: UFix64
  pub(set) var art: [Art.ArtData]
  init (_ address:Address) {
    self.address=address
    self.balance= 0.0
    self.art= []
  }
}

/*
  This script will check an address and print out its FT, NFT and Versus resources
 */
pub fun main(address:Address) : AddressStatus {
    // get the accounts' public address objects
    let account = getAccount(address)
    let status= AddressStatus(address)
    
    if let vault= account.getCapability(/public/flowTokenBalance).borrow<&{FungibleToken.Balance}>() {
       status.balance=vault.balance
    }

    status.art= Art.getArt(address: address)
    
    return status

}
