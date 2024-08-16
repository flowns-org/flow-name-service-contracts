import FungibleToken from 0xFungibleToken

access(all) fun main(address: Address) : UFix64 {
    let account = getAccount(address)
    var balance = 0.00
    if let vault = account.capabilities.borrow<&{FungibleToken.Balance}>(/public/flowTokenBalance) {
      balance = vault.balance
    }
    return balance
}
