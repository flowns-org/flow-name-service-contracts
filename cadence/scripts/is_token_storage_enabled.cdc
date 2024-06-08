import FungibleToken from 0xFungibleToken
import <Token> from <TokenAddress>

pub fun main(address: Address) : Bool {
    let receiver: Bool = getAccount(address)
    .getCapability<&<Token>.Vault{FungibleToken.Receiver}>(<TokenReceiverPath>)
    .check()
    let balance: Bool = getAccount(address)
    .getCapability<&<Token>.Vault{FungibleToken.Balance}>(<TokenBalancePath>)
    .check()
    return receiver && balance
}