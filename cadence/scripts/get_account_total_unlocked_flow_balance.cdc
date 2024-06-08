import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import LockedTokens from 0xLockedTokens

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)

    let unlockedVault = account
      .getCapability(/public/flowTokenBalance)!
      .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")
    let unlockedBalance = unlockedVault.balance
    
    return unlockedBalance
}