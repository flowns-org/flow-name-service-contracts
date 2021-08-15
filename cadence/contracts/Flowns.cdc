
import FungibleToken from "./standard/FungibleToken.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import Domains from "./Domains.cdc"


// Flowns is the core contract of FNS, Flowns define Root domain and admin resource
pub contract Flowns {
  // paths
  pub let FlownsAdminPublicPath: PublicPath
  pub let FlownsAdminStoragePath: StoragePath
  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPrivatePath: PrivatePath

  // variables
  pub var totalRootDomains: UInt64
  // status that set register pause or not
  pub var isPause: Bool

  // events
  pub event RootDomainDestroyed(id: UInt64)

  pub event RootDomainCreated(name: String, nameHash: String, id: UInt64)

  pub event RenewDomain(name: String, nameHash: String, duration: UFix64, price: UFix64)
  
  pub event RootDomainPriceChanged(name: String, key: Int, price: UFix64)

  pub event RootDomainVaultWithdrawn(name: String, amount: UFix64)

  pub event RootDomainServerAdded()

  pub event FlownsAdminCreated()

  pub event RootDomainVaultChanged()

  pub event FlownsPaused()

  pub event FlownsActivated()


  // structs 
  pub struct RootDomainInfo {
    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let domainCount: UInt64

    init(
      id: UInt64,
      name: String,
      nameHash: String,
      domainCount: UInt64,
    ) {
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.domainCount = domainCount
    }
  }

  // resources
  // Rootdomain is the root of domain name
  // ex. domain 'fns.flow' 'flow' is the root domain name, and save as a resource by RootDomain
  pub resource RootDomain {
    pub let id: UInt64

    pub let name: String
    
    // namehash is calc by eth-ens-namehash
    pub let nameHash: String

    pub var domainCount: UInt64

    // Here is the vault to receive domain rent fee, every root domain has his own vault
    // you can call Flowns.getRootVaultBalance to get balance
    priv var domainVault: @FungibleToken.Vault

    // Here is the prices store for domain rent fee
    // When user register or renew a domain ,the rent price is get from here, and price store by {domains length: flow per second}
    // If cannot get price, then register will not open
    pub var prices:{Int: UFix64}

    // Server store the collection private resource to manage the domains
    // Server need to init before open register
    access(self) var server: Capability<&Domains.Collection>?

    init(id: UInt64, name: String, nameHash: String, vault: @FungibleToken.Vault){
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.domainCount = 0
      self.domainVault <- vault
      self.prices = {}
      self.server = nil
    }

    // Set CollectionPrivate to RootDomain resource
    pub fun addCapability(_ cap: Capability<&Domains.Collection>) {
      pre {
        cap.check() : "Invalid server capablity"
        self.server == nil : "Server already set"
      }
      self.server = cap
      
      emit RootDomainServerAdded()

    }

    // Query root domain info
    pub fun getRootDomainInfo() : RootDomainInfo {
      return RootDomainInfo(
        id: self.id,
        name: self.name,
        nameHash: self.nameHash,
        domainCount: self.domainCount
      )
    }

    // Query root domain vault balance
    pub fun getVaultBalance() : UFix64 {
      pre {
        self.domainVault != nil : "Vault not init yet..."
      }
      return self.domainVault.balance
    }

    // Mint domain
    access(account) fun mintDomain(name: String, nameHash: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
      pre {
        self.server != nil : "Domains collection has not been linked to the server"
      }

      let expiredTime = getCurrentBlock().timestamp + duration
      self.server!.borrow()!.mintDomain(id: self.domainCount, name: name, nameHash: nameHash, parentName: self.name, expiredAt: expiredTime, receiver: receiver)
      self.domainCount = self.domainCount + (1 as UInt64)

    }
    // Set domain rent fee
    pub fun setPrices(key: Int, price: UFix64) {
      self.prices[key]= price
      
      emit RootDomainPriceChanged(name: self.name, key: key, price: price)
    }

    // Renew domain
    pub fun renewDomain(domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault) {
      pre {
        !Domains.isDeprecated(nameHash: domain.nameHash, domainId: domain.id) : "Domain already deprecated ..."
      }
      // When domain name longer than 10, the price will set by 10 price
      var len = domain.name.length
      if len > 10 {
        len = 10
      }
      let price = self.prices[len]

      if domain.parent != self.name {
        panic("domain not root domain's sub domain")
      }
      // Renew duration need longer than one year 60 * 60 * 24 * 365 = 3153600 second
      if duration < 3153600.0 {
        panic("duration must geater than 3153600 ")
      }
      if price == 0.0 {
        panic("Can not renew domain")
      }
      
      // Calc rent price
      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance
      
      // check the rent fee
      if rentFee < rentPrice {
        panic("Not enough fee to renew your domain.")
      }

      // Receive rent fee
      self.domainVault.deposit(from: <- feeTokens)

      let expiredAt = Domains.expired[domain.nameHash]! + UFix64(duration)
      // Update domain's expire time with Domains expired mapping
      domain.setExpired(expiredAt: expiredAt)

      emit RenewDomain(name: domain.name, nameHash: domain.nameHash, duration: duration, price: rentFee )

    }

    // Register domain
    pub fun registerDomain(name: String, nameHash: String, duration: UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
      pre {
        self.server != nil : "Your client has not been linked to the server"
        Flowns.available(nameHash: nameHash) == true : "Domain not available"
      }
      // same as renew domain
      var len = name.length
      if len > 10 {
        len = 10
      }

      let price = self.prices[len]
      // limit the register and renew time longer than one year
      if duration < 3153600.0 {
        panic("duration must geater than 3153600")
      }
      if price == 0.0 || price == nil {
        panic("Can not register domain")
      }

      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance

      if rentFee < rentPrice {
         panic("Not enough fee to rent your domain.")
      }

      let expiredTime = getCurrentBlock().timestamp + UFix64(duration)

      self.domainVault.deposit(from: <- feeTokens)

      self.server!.borrow()!.mintDomain(id: self.domainCount, name: name, nameHash: nameHash, parentName: self.name, expiredAt: expiredTime, receiver: receiver)

      self.domainCount = self.domainCount + (1 as UInt64)

    }
    // Withdraw vault fee 
    access(account) fun withdrawVault(receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      let vault = receiver.borrow()!
      vault.deposit(from: <- self.domainVault.withdraw(amount: amount))
      
      emit RootDomainVaultWithdrawn(name: self.name, amount: amount)
    }

    access(account) fun changeRootDomainVault(vault: @FungibleToken.Vault) {

      let balance = self.getVaultBalance()

      if balance > 0.0 {
        panic("Please withdraw the balance of the previous vault first ")
      }

      let preVault <- self.domainVault <- vault
      
      // clean the price
      self.prices = {}
      emit RootDomainVaultChanged()
      destroy preVault
    }

    destroy(){
        log("Destroy Root domains")
        destroy self.domainVault
        emit RootDomainDestroyed(id: self.id)
    }

  }


  // Root domain public interface for fns user
  pub resource interface RootDomainPublic {

    pub fun getDomainInfo(domainId: UInt64) : RootDomainInfo

    pub fun getAllDomains(): {UInt64: RootDomainInfo}

    pub fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault)

    pub fun registerDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> )

    pub fun getPrices(domainId: UInt64): {Int: UFix64}

    pub fun getVaultBalance(domainId: UInt64): UFix64

  }

  // Manager resource
  pub resource interface DomainAdmin {

    access(account) fun createRootDomain(
      name: String, 
      nameHash: String,
      vault: @FungibleToken.Vault
    )

    access(account) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64)

    access(account) fun changeRootDomainVault(domainId: UInt64, vault: @FungibleToken.Vault)

    access(account) fun setPrices(domainId: UInt64, len: Int, price: UFix64)
    
    access(account) fun mintDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)
  }

  // Root domain Collection 
  pub resource RootDomainCollection: RootDomainPublic, DomainAdmin {
    // Root domains
    access(account) var domains: @{UInt64: RootDomain}

    init(
    ) {
      self.domains <- {}
    }

    // Create root domain
    access(account) fun createRootDomain(
      name: String, 
      nameHash: String,
      vault: @FungibleToken.Vault
    ) {

      let rootDomain  <- create RootDomain(
        id: Flowns.totalRootDomains,
        name: name,
        nameHash: nameHash,
        vault: <- vault
      )

      Flowns.totalRootDomains = Flowns.totalRootDomains + 1 as UInt64
      emit RootDomainCreated(name: name, nameHash: nameHash,  id: rootDomain.id)

      let oldDomain <- self.domains[rootDomain.id] <- rootDomain
      destroy oldDomain
    }

    pub fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault){
      pre {
          self.domains[domainId] != nil : "Root domain not exist..."
        }
      let root = self.getRootDomain(domainId)
      root.renewDomain(domain: domain, duration: duration, feeTokens: <- feeTokens)
    }

    pub fun registerDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let root = self.getRootDomain(domainId)
      root.registerDomain(name: name, nameHash: nameHash, duration: duration, feeTokens: <-feeTokens, receiver: receiver )
    }

    pub fun getVaultBalance(domainId: UInt64): UFix64 {
        pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let rootRef = &self.domains[domainId] as? &RootDomain

      return rootRef.getVaultBalance()
    }

    access(account) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      self.getRootDomain(domainId).withdrawVault(receiver: receiver, amount: amount)
    }

    access(account) fun changeRootDomainVault(domainId: UInt64, vault: @FungibleToken.Vault) {
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      self.getRootDomain(domainId).changeRootDomainVault(vault: <- vault)
    }

    access(account) fun mintDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>) {
        pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let root = self.getRootDomain(domainId)
      root.mintDomain(name: name, nameHash: nameHash, duration: duration, receiver: receiver)
    }

    // Get all root domains
    pub fun getAllDomains(): {UInt64: RootDomainInfo} {
      var domainInfos: {UInt64: RootDomainInfo }= {}
      for id in self.domains.keys {
        let itemRef = &self.domains[id] as? &RootDomain
        domainInfos[id] = itemRef.getRootDomainInfo()
      }
      return domainInfos
    }
    
    access(account) fun setPrices(domainId: UInt64, len: Int, price: UFix64){
      self.getRootDomain(domainId).setPrices(key: len, price: price)
    }

    // get domain reference
    access(contract) fun getRootDomain(_ domainId: UInt64) : &RootDomain {
      pre {
        self.domains[domainId] != nil: "domain doesn't exist"
      }
      return &self.domains[domainId] as &RootDomain
    }

    // get Root domain info
    pub fun getDomainInfo(domainId: UInt64): RootDomainInfo {
      return self.getRootDomain(domainId).getRootDomainInfo()
    }

    // Query root domain's rent price
    pub fun getPrices(domainId: UInt64): {Int: UFix64} {
      return self.getRootDomain(domainId).prices
    }


    destroy() {            
        destroy self.domains
    }
  }

  // Admin interface resource
  pub resource interface AdminPublic {

    pub fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>)

    pub fun addRootDomainCapability(domainId: UInt64, cap: Capability<&Domains.Collection>)

    pub fun createRootDomain(name: String, nameHash: String, vault: @FungibleToken.Vault)

    pub fun setRentPrice(domainId: UInt64, len: Int, price: UFix64)

    pub fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64)

    pub fun changeRootDomainVault(domainId: UInt64, vault: @FungibleToken.Vault)
    
    pub fun mintDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)

    pub fun updateRecords(nameHash: String, address: Address?) 

    pub fun setPause(_ flag: Bool)
  }


  pub resource Admin: AdminPublic {

    access(self) var server: Capability<&Flowns.RootDomainCollection>?

    init() {
      // Server is the root collection for manager to create and store root domain
      self.server = nil
    }

    // init RootDomainCollection for admin
    pub fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>) {
      pre {
        cap.check() : "Invalid server capablity"
        self.server == nil : "Server already set"
      }
        self.server = cap
    }

    // init Root domain's Domains collection to create collection for domain register 
    pub fun addRootDomainCapability(domainId: UInt64, cap: Capability<&Domains.Collection>) {
      pre {
          cap.check() : "Invalid server capablity"
      }
      self.server!.borrow()!.getRootDomain(domainId).addCapability(cap)
    }

    // Create root domain with admin
    pub fun createRootDomain(name: String, nameHash: String, vault: @FungibleToken.Vault) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.createRootDomain(name: name, nameHash: nameHash, vault: <- vault)
    }

    // Set rent price
    pub fun setRentPrice(domainId: UInt64, len: Int, price: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.setPrices(domainId: domainId, len: len, price: price)
    }

    // Withdraw vault 
    pub fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.withdrawVault(domainId: domainId, receiver: receiver, amount: amount)
    }

    // update records 
    pub fun updateRecords(nameHash: String, address: Address?) {
      Domains.updateRecords(nameHash: nameHash, address: address)
    }

    // Withdraw vault 
    pub fun changeRootDomainVault(domainId: UInt64, vault: @FungibleToken.Vault) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.changeRootDomainVault(domainId: domainId, vault: <- vault)
    }

    // Mint domain with root domain
    pub fun mintDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64,receiver: Capability<&{NonFungibleToken.Receiver}>) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.mintDomain(domainId: domainId, name: name, nameHash: nameHash, duration: duration, receiver: receiver)
    }

    pub fun setPause(_ flag: Bool) {
      pre {
        Flowns.isPause != flag : "Already done!"
      }
      Flowns.isPause = flag
      if flag == true {
        emit FlownsPaused()
      } else {
        emit FlownsActivated()
      }
    }

  }

  // Create admin resource
  priv fun createAdminClient(): @Admin {
    emit FlownsAdminCreated()
    return <- create Admin()
  }
  
  // Query root domain
  pub fun getRootDomainInfo(domainId: UInt64) : RootDomainInfo? {
    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    if let collection = rootCollectionCap.borrow()  {
      return collection.getDomainInfo(domainId: domainId)
    }
    return nil
  }
  // Query all root domain
  pub fun getAllRootDomains(): {UInt64: RootDomainInfo}? {

    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    if let collection = rootCollectionCap.borrow()  {
        return collection.getAllDomains()
    }
    return nil
  }
  
  // Check domain available 
  pub fun available(nameHash: String): Bool {

    if Domains.records[nameHash] == nil {
      return true
    }
    return Domains.isExpired(nameHash)
  }

  pub fun getRentPrices(domainId: UInt64): {Int: UFix64} {

    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    if let collection = rootCollectionCap.borrow()  {
      return collection.getPrices(domainId: domainId)
    }
    return {}
  }

  pub fun getRootVaultBalance(domainId: UInt64): UFix64 {

    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    let collection = rootCollectionCap.borrow()?? panic("Could not borrow collection ")
    let balance = collection.getVaultBalance(domainId: domainId)
    return balance
  }

  pub fun registerDomain(domainId: UInt64, name: String, nameHash: String, duration: UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
    pre {
      Flowns.isPause == false : "Register pause"
    }
    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    let collection = rootCollectionCap.borrow() ?? panic("Could not borrow collection ")
    collection.registerDomain(domainId: domainId, name: name, nameHash: nameHash, duration: duration, feeTokens: <-feeTokens, receiver: receiver)
  }
  
  pub fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @FungibleToken.Vault) {
    pre {
      Flowns.isPause == false : "Renewer pause"
    }
    let account = Flowns.account
    let rootCollectionCap = account.getCapability<&{Flowns.RootDomainPublic}>(self.CollectionPublicPath)
    let collection = rootCollectionCap.borrow() ?? panic("Could not borrow collection ")
    collection.renewDomain(domainId: domainId, domain: domain, duration: duration, feeTokens: <-feeTokens)
  }
  
  init() {

    self.CollectionPublicPath = /public/flownsCollection
    self.CollectionPrivatePath = /private/flownsCollection
    self.CollectionStoragePath = /storage/flownsCollection
    self.FlownsAdminPublicPath = /public/flownsAdmin
    self.FlownsAdminStoragePath =/storage/flownsAdmin

    let account = self.account
    let admin <- Flowns.createAdminClient()

    account.save<@Flowns.Admin>(<-admin, to: Flowns.FlownsAdminStoragePath)
    self.totalRootDomains = 0
    self.isPause = true
    log("Setting up flowns capability")
    let collection <- create RootDomainCollection()
    account.save(<-collection, to: Flowns.CollectionStoragePath)
    account.link<&{Flowns.RootDomainPublic}>(Flowns.CollectionPublicPath, target: Flowns.CollectionStoragePath)
    account.link<&Flowns.RootDomainCollection>(Flowns.CollectionPrivatePath, target: Flowns.CollectionStoragePath)
    account.link<&Flowns.Admin{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath, target: Flowns.FlownsAdminStoragePath)
  }
}