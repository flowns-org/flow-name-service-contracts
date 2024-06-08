import LockedTokens from 0xLockedTokens

pub fun main(address: Address): Bool {
    let account = getAccount(address)
    let lockedAccountInfoCap = account
      .getCapability
      <&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>
      (LockedTokens.LockedAccountInfoPublicPath)
    if lockedAccountInfoCap == nil || !(lockedAccountInfoCap!.check()) {
        return false
    }
    return true
}