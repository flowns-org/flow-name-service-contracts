
import FungibleToken from "./standard/FungibleToken.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import Domains from "./Domains.cdc"
import FlowToken from "./standard/FlowToken.cdc"




pub contract Flowns {

  // paths
  pub let FlownsAdminPublicPath: PublicPath
  pub let FlownsAdminStoragePath: StoragePath
  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPrivatePath: PrivatePath

  // variables

  pub var totalRootDomains: UInt64


  // events
  pub event RootDomainDestroyed(id:UInt64)

  pub event RootDomainCreated(name:String, id: UInt64)

  pub event RenewDomain(name: String, duration: UFix64, price: UFix64)


  // structs
  pub struct RootDomainInfo {
    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let domainCount: UInt64
    // pub let domainRegistry: String //todo registry info

    init(
      id: UInt64,
      name: String,
      nameHash: String,
      domainCount: UInt64,
    ) {
      self.id = id
      self.name=name
      self.nameHash=nameHash
      self.domainCount=domainCount
      // self.domainRegistry=nil
    }
  }

  // resources
  pub resource RootDomain {
    pub let id: UInt64

    pub let name:String

    pub let nameHash:String

    pub var domainCount:UInt64

    priv let domainVault: @FungibleToken.Vault

    pub var domains: {String: Address}

    pub var prices:{Int: UFix64}

    access(self) var server: Capability<&Domains.Collection>?

    
    // sub domain refs
    // access(contract) var domainCapability: Capability<&Domain.Collection>

    init(id:UInt64, name:String, nameHash:String){
      self.id = id
      self.name = name
      self.nameHash = nameHash // TODO 
      self.domainCount = 0
      self.domainVault <- FlowToken.createEmptyVault()
      self.domains = {}
      self.prices = {}
      self.server = nil
    }

    pub fun addCapability(_ cap: Capability<&Domains.Collection>) {
        pre {
            cap.check() : "Invalid server capablity"
            self.server == nil : "Server already set"
        }
        self.server = cap
    }

    pub fun getRootDomainInfo() : RootDomainInfo {
      return RootDomainInfo(
        id:self.id,
        name: self.name,
        nameHash: self.nameHash,
        domainCount: self.domainCount
      )
    }

    pub fun available(nameHash:String): Bool {
      return self.domains[nameHash] == nil
    }

    access(account) fun mintDomain(id: UInt64, name:String, nameHash:String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
      pre {
          self.server != nil : "Your client has not been linked to the server"
      }

      Flowns.totalRootDomains = Flowns.totalRootDomains + 1 as UInt64
      
      let expiredTime = getCurrentBlock().timestamp + UFix64(duration)
      self.domains[nameHash] = receiver.address
      self.server!.borrow()!.mintDomain(id:self.domainCount, name:name, nameHash: nameHash, parentName: self.name, expiredAt:expiredTime, receiver:receiver)
      self.domainCount = self.domainCount + (1 as UInt64)
    }
    

    pub fun setPrices(key:Int, price: UFix64) {
      self.prices[key]= price
      // emit
    }



    pub fun renewDomain(domainCap: Capability<&{Domains.DomainPublic}>, duration: UFix64, feeTokens: @FungibleToken.Vault) {
    
      let domain = domainCap.borrow()!
      let length = domain.name.length
      let price = self.prices[length]
      if domain.parent != self.name {
        panic("domain not root domain's sub domain")
      }
      if duration < 3153600.0 {
        panic("duration must geater than 3153600 ")
      }
      if price == 0.0 {
        panic("Can not renew domain")
      }

      // let expiredAt = domainCap.expiredAt
      // let currentTimestamp = getCurrentBlock().timestamp
      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance

      if rentFee < rentPrice {
         panic("Not enough fee to renew your domain.")
      }

      self.domainVault.deposit(from: <- feeTokens)
      let expiredTime = Domains.expired[domain.nameHash]! + UFix64(duration)
      Domains.expired[domain.nameHash] = expiredTime

      emit RenewDomain(name:domain.name, duration: duration, price: rentFee )

    }

    pub fun registerDomain(name:String, nameHash:String, duration:UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
      pre {
        self.server != nil : "Your client has not been linked to the server"
        self.domains[nameHash] == nil: "Domain not available"
      }
      
      let length = name.length
      let price = self.prices[length]
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
      // todo create domain
      self.server!.borrow()!.mintDomain(id:self.domainCount, name:name, nameHash: nameHash, parentName: self.name, expiredAt:expiredTime, receiver:receiver)
      self.domainCount = self.domainCount + (1 as UInt64)

    }

    access(account) fun withdrawVault(receiver:Capability<&{FungibleToken.Receiver}>){
      let vault = receiver.borrow()!
      vault.deposit(from: <- self.domainVault.withdraw(amount: self.domainVault.balance))
    }

    

    destroy(){
        log("Destroy Root domains")
        destroy self.domainVault
        emit RootDomainDestroyed(id: self.id)
    }

  }



    pub resource interface DomainPublic {

        pub fun getDomainInfo(domainId: UInt64) : RootDomainInfo

        pub fun getAllDomains(): {UInt64: RootDomainInfo}

        pub fun renewDomain(domainId: UInt64, domainCap: Capability<&{Domains.DomainPublic}>, duration: UFix64, feeTokens: @FungibleToken.Vault)

        pub fun registerDomain(domainId: UInt64, name:String, nameHash:String, duration:UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> )

        pub fun getPrices(domainId:UInt64): {Int:UFix64}

        pub fun available(domainId:UInt64, nameHash:String):Bool
    }

  pub resource interface DomainAdmin {

      access(account) fun createRootDomain(
          name: String, 
          nameHash: String,
        )
      access(account) fun withdrawVault(domainId:UInt64, receiver:Capability<&{FungibleToken.Receiver}>)

      access(account) fun setPrices(domainId:UInt64, len:Int, price:UFix64)
  }

  pub resource RootDomainCollection: DomainPublic, DomainAdmin {
      access(account) var domains: @{UInt64: RootDomain}

      init(
      ) {
        self.domains <- {}
      }

      // When creating a drop you send in an NFT and the number of editions you want to sell vs the unique one
      // There will then be minted edition number of extra copies and put into the editions auction
      access(account) fun createRootDomain(
        name: String, 
        nameHash: String,
        ) {

        let rootDomain  <- create RootDomain(
          id: Flowns.totalRootDomains,
          name:name,
          nameHash:nameHash
          )

        emit RootDomainCreated(name: name, id: rootDomain.id)
        Flowns.totalRootDomains = Flowns.totalRootDomains + 1 as UInt64
        let oldDomain <- self.domains[rootDomain.id] <- rootDomain
        destroy oldDomain

      }

      pub fun renewDomain(domainId: UInt64, domainCap: Capability<&{Domains.DomainPublic}>, duration: UFix64, feeTokens: @FungibleToken.Vault){
        pre {
             self.domains[domainId] != nil : "Root domain not exist..."
          }
        let root = self.getDomain(domainId)
        root.renewDomain(domainCap:domainCap, duration: duration, feeTokens: <- feeTokens)
      }

      pub fun registerDomain(domainId: UInt64, name:String, nameHash:String, duration:UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
        pre {
            self.domains[domainId] != nil : "Root domain not exist..."
        }
        let root = self.getDomain(domainId)
        root.registerDomain(name:name, nameHash:nameHash, duration:duration, feeTokens: <-feeTokens, receiver:receiver )
      }


      access(account) fun withdrawVault(domainId:UInt64, receiver:Capability<&{FungibleToken.Receiver}>){
        pre {
          self.domains[domainId] != nil : "Root domain not exist..."
        }
         self.getDomain(domainId).withdrawVault(receiver:receiver)
      }

      // Get all the domain info
      pub fun getAllDomains(): {UInt64: RootDomainInfo} {
          var domainInfos: {UInt64: RootDomainInfo }= {}
          for id in self.domains.keys {
              let itemRef = &self.domains[id] as? &RootDomain
              domainInfos[id] = itemRef.getRootDomainInfo()
          }
          return domainInfos

      }
      // 
      access(account) fun setPrices(domainId:UInt64, len:Int, price:UFix64){
        self.getDomain(domainId).setPrices(key: len, price: price)
      }

      access(contract) fun getDomain(_ domainId:UInt64) : &RootDomain {
          pre {
              self.domains[domainId] != nil:
                  "domain doesn't exist"
          }
          return &self.domains[domainId] as &RootDomain
      }

      pub fun getDomainInfo(domainId:UInt64): RootDomainInfo {
          return self.getDomain(domainId).getRootDomainInfo()
      }

      pub fun getPrices(domainId:UInt64): {Int:UFix64} {
          return self.getDomain(domainId).prices
      }

      pub fun available(domainId:UInt64, nameHash:String): Bool {
        return self.getDomain(domainId).available(nameHash: nameHash)
      }

      destroy() {            
          destroy self.domains
      }
    }

    //
    pub resource interface AdminPublic {
        pub fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>)
        pub fun addRootDomainCapability(domainId:UInt64, cap: Capability<&Domains.Collection>)
        pub fun createRootDomain(name: String, nameHash: String) 
        pub fun setRentPrice(domainId:UInt64, len:Int, price:UFix64) 
    }

    // 
    pub resource Admin: AdminPublic {

        access(self) var server: Capability<&Flowns.RootDomainCollection>?

        init() {
            self.server = nil
        }

        pub fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>) {
            pre {
                cap.check() : "Invalid server capablity"
                self.server == nil : "Server already set"
            }
            self.server = cap
        }

         pub fun addRootDomainCapability(domainId:UInt64, cap: Capability<&Domains.Collection>) {
            pre {
                cap.check() : "Invalid server capablity"
            }
            self.server!.borrow()!.getDomain(domainId).addCapability(cap)
        }

        // withdraw vault balance
        // pub fun withdraw(_ domainId: UInt64) {
        //  pre {
        //    self.server != nil : "Your client has not been linked to the server"
        //  }
        //  self.server!.borrow()!.withdraw()
        // }
      
        pub fun createRootDomain(
          name: String, 
          nameHash: String
          ) {
          pre {
              self.server != nil : "Your client has not been linked to the server"
          }
          self.server!.borrow()!.createRootDomain(name:name, nameHash:nameHash)
        }

        pub fun setRentPrice(domainId:UInt64, len:Int, price:UFix64) {
           pre {
              self.server != nil : "Your client has not been linked to the server"
          }
          self.server!.borrow()!.setPrices(domainId: domainId, len: len, price: price)
        }

    }

 //make it possible for a user that wants to be a versus admin to create the client
    pub fun createAdminClient(): @Admin {
        return <- create Admin()
    }
    
    // funs 
    pub fun getRootDomainInfo(domainId: UInt64) : RootDomainInfo? {
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      if let collection = rootCollectionCap.borrow()  {
          return collection.getDomainInfo(domainId: domainId)
      }
      return nil
    }

    pub fun getAllRootDomains(): {UInt64: RootDomainInfo}? {
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      if let collection = rootCollectionCap.borrow()  {
          return collection.getAllDomains()
      }
      return nil
    }
    
    pub fun available(domainId: UInt64, nameHash: String): Bool {
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      if let collection = rootCollectionCap.borrow()  {
        return collection.available(domainId: domainId, nameHash: nameHash)
      }
      return false
    }

    pub fun getRentPrices(domainId: UInt64): {Int: UFix64} {
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      if let collection = rootCollectionCap.borrow()  {
        return collection.getPrices(domainId: domainId)
      }
      return {}
    }

    pub fun registerDomain(domainId: UInt64, name:String, nameHash:String, duration:UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{NonFungibleToken.Receiver}> ){
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      let collection = rootCollectionCap.borrow() ?? panic("Could not borrow admin client")
      collection.registerDomain(domainId: domainId, name: name, nameHash: nameHash, duration: duration, feeTokens: <-feeTokens, receiver: receiver)
    }
    
     pub fun renewDomain(domainId: UInt64, domainCap: Capability<&{Domains.DomainPublic}>, duration: UFix64, feeTokens: @FungibleToken.Vault) {
      let account = Flowns.account
      let rootCollectionCap=account.getCapability<&{Flowns.DomainPublic}>(self.CollectionPublicPath)
      let collection = rootCollectionCap.borrow() ?? panic("Could not borrow admin client")
      collection.renewDomain(domainId: domainId, domainCap:domainCap, duration:duration, feeTokens: <-feeTokens)
    }
    

    

    //initialize all the paths and create and link up the admin proxy
    //init is only executed on initial deployment
    init() {

        self.CollectionPublicPath= /public/flownsCollection
        self.CollectionPrivatePath= /private/flownsCollection
        self.CollectionStoragePath= /storage/flownsCollection
        self.FlownsAdminPublicPath= /public/flownsAdmin
        self.FlownsAdminStoragePath=/storage/flownsAdmin

        let account=self.account
        self.totalRootDomains =0
        
        // self.rootDomainMapping = {}
        let FlownsReceiver=account.getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        
        log("Setting up flowns capability")
        let collection <- create RootDomainCollection()
        account.save(<-collection, to: Flowns.CollectionStoragePath)
        account.link<&{Flowns.DomainPublic}>(Flowns.CollectionPublicPath, target: Flowns.CollectionStoragePath)
        account.link<&Flowns.RootDomainCollection>(Flowns.CollectionPrivatePath, target: Flowns.CollectionStoragePath)
    }

}