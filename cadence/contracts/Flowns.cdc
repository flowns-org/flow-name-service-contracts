
import FungibleToken from "./standard/FungibleToken.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import Domains from "./Domains.cdc"
import FNSConfig from "./FNSConfig.cdc"

// Flowns is the core contract of FNS, Flowns define Root domain and admin resource
access(all) contract Flowns {
  // paths
  access(all) let FlownsAdminPrivatePath: PrivatePath
  access(all) let FlownsAdminStoragePath: StoragePath
  access(all) let CollectionStoragePath: StoragePath
  access(all) let CollectionPublicPath: PublicPath
  // access(all) let CollectionPrivatePath: PrivatePath

  // variables
  access(all) var totalRootDomains: UInt64
  // status that set register pause or not
  access(self) var isPause: Bool
  // for domain name on-chain validator 
  access(self) var forbidChars: String
  // events


  access(all) event RootDomainDestroyed(id: UInt64)

  access(all) event RootDomainCreated(name: String, nameHash: String, id: UInt64)

  access(all) event RenewDomain(name: String, nameHash: String, duration: UFix64, price: UFix64)
  
  access(all) event RootDomainPriceChanged(name: String, key: Int, price: UFix64)

  access(all) event RootDomainVaultWithdrawn(name: String, amount: UFix64)

  access(all) event RootDomainServerAdded()

  access(all) event FlownsAdminCreated()

  access(all) event RootDomainVaultChanged()

  access(all) event FlownsPaused()

  access(all) event FlownsActivated()

  access(all) event FlownsForbidCharsUpdated(before: String, after: String)

  access(all) event RootDomainMaxLengthUpdated(domainId: UInt64, before: Int, after: Int)

  access(all) event RootDomainCommissionRateUpdated(domainId: UInt64, before: UFix64, after: UFix64)

  access(all) event RootDomainMintDurationUpdated(domainId: UInt64, before: UFix64, after: UFix64)

  access(all) event DomainRegisterCommissionAllocated(domainId: UInt64, nameHash: String, amount: UFix64, commissionAmount: UFix64, refer: Address, receiveId: UInt64)


  // structs 
  access(all) struct RootDomainInfo {
    access(all) let id: UInt64
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let domainCount: UInt64
    access(all) let minRentDuration: UFix64
    access(all) let maxDomainLength: Int
    access(all) let prices: {Int: UFix64}
    access(all) let commissionRate: UFix64


    init(
      id: UInt64,
      name: String,
      nameHash: String,
      domainCount: UInt64,
      minRentDuration: UFix64,
      maxDomainLength: Int,
      prices: {Int: UFix64},
      commissionRate: UFix64
    ) {
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.domainCount = domainCount
      self.minRentDuration = minRentDuration
      self.maxDomainLength = maxDomainLength
      self.prices = prices
      self.commissionRate = commissionRate
    }
  }

  // resources
  // Rootdomain is the root of domain name
  // ex. domain 'fns.flow' 'flow' is the root domain name, and save as a resource by RootDomain
  access(all) resource RootDomain {
    access(all) let id: UInt64

    access(all) let name: String
    
    // namehash is calc by eth-ens-namehash
    access(all) let nameHash: String

    access(all) var domainCount: UInt64

    // Here is the vault to receive domain rent fee, every root domain has his own vault
    // you can call Flowns.getRootVaultBalance to get balance
    access(self) var domainVault: @{FungibleToken.Vault}

    // Here is the prices store for domain rent fee
    // When user register or renew a domain ,the rent price is get from here, and price store by {domains length: flow per second}
    // If cannot get price, then register will not open
    access(self) var prices: {Int: UFix64}

    access(self) var minRentDuration: UFix64

    access(self) var maxDomainLength: Int

    access(self) var commissionRate: UFix64

    // Server store the collection private resource to manage the domains
    // Server need to init before open register
    access(self) var server: Capability<&Domains.Collection>?

    init(id: UInt64, name: String, nameHash: String, vault: @{FungibleToken.Vault}){
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.domainCount = 0
      self.domainVault <- vault
      self.prices = {}
      self.server = nil
      self.minRentDuration = 31536000.00
      self.maxDomainLength = 30
      self.commissionRate = 0.0
    }

    // Set CollectionPrivate to RootDomain resource
    access(all) fun addCapability(_ cap: Capability<&Domains.Collection>) {
      pre {
        cap.check() : "Invalid server capablity"
        self.server == nil : "Server already set"
      }
      self.server = cap
      
      emit RootDomainServerAdded()

    }

    // Query root domain info
    access(all) fun getRootDomainInfo() : RootDomainInfo {
      return RootDomainInfo(
        id: self.id,
        name: self.name,
        nameHash: self.nameHash,
        domainCount: self.domainCount,
        minRentDuration: self.minRentDuration,
        maxDomainLength: self.maxDomainLength,
        prices: self.prices,
        commissionRate: self.commissionRate

      )
    }

    // Query root domain vault balance
    access(all) fun getVaultBalance() : UFix64 {
      pre {
        self.domainVault != nil : "Vault not init yet..."
      }
      return self.domainVault.balance
    }

    // Deposit fee to domain Vault
    access(all) fun depositVault(fee: @{FungibleToken.Vault}) {
      pre {
        self.domainVault != nil : "Vault not init yet..."
      }
      self.domainVault.deposit(from: <- fee)
    }

    access(all) fun getPrices(): {Int: UFix64} {
      return self.prices
    }

    // Mint domain
    access(account) fun mintDomain(name: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
      pre {
        self.server != nil : "Domains collection has not been linked to the server"
      }
      let nameHash = Flowns.getDomainNameHash(name: name, parentNameHash: self.nameHash)
    
      let expiredTime = getCurrentBlock().timestamp + duration

      self.server!.borrow()!.mintDomain(name: name, nameHash: nameHash, parentName: self.name, expiredAt: expiredTime, receiver: receiver)
      self.domainCount = self.domainCount + (1 as UInt64)

    }
    // Set domain rent fee
    access(all) fun setPrices(key: Int, price: UFix64) {
      self.prices[key]= price
      
      emit RootDomainPriceChanged(name: self.name, key: key, price: price)
    }

    access(account) fun setMinRentDuration(_ duration: UFix64) {
      let oldDuration = self.minRentDuration
      self.minRentDuration = duration

      emit RootDomainMintDurationUpdated(domainId: self.id, before: oldDuration, after: duration)
    }

    access(account) fun setMaxDomainLength(_ length: Int) {
      let oldLength = self.maxDomainLength
      self.maxDomainLength = length

      emit RootDomainMaxLengthUpdated(domainId: self.id, before: oldLength, after: length)
    }

    access(account) fun setCommissionRate(_ rate: UFix64) {
      let oldRate = self.commissionRate
      self.commissionRate = rate

      emit RootDomainCommissionRateUpdated(domainId: self.id, before: oldRate, after: rate)
    }

    access(contract) fun _distributeCommission(feeTokens: @{FungibleToken.Vault}, refer: Address, from: Address?): @{FungibleToken.Vault} {
      let rentFee = feeTokens.balance
      let commissionFee  = rentFee * self.commissionRate
        
      let referAcc = getAccount(refer!)

      let collection = referAcc.capabilities.borrow<&Domains.Collection>(Domains.CollectionPublicPath) 
      // let collection = collectionCap.borrow()
      if collection != nil {
        let ids = collection!.getIDs()
        var defaultDomain: &Domains.NFT? = nil
        defaultDomain = collection!.borrowDomain(id: ids[0])!
        if ids.length > 0 {
          for id in ids {
            let domain = collection!.borrowDomain(id: id)!
            let isDefault = domain.getText(key: "isDefault")
            if isDefault == "true" {
              defaultDomain = domain
            }
          }
          if defaultDomain!.receivable == true && !Domains.isExpired(defaultDomain!.nameHash) {
            defaultDomain!.depositVault(from: <- feeTokens.withdraw(amount: commissionFee), senderRef: nil)
            emit DomainRegisterCommissionAllocated(domainId: self.id, nameHash: defaultDomain!.nameHash, amount: rentFee, commissionAmount: commissionFee, refer: refer!, receiveId: defaultDomain!.id)
          }
        }
      }
      return <- feeTokens
    }


    // Renew domain
    access(all) fun renewDomain(domain: &Domains.NFT, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?) {
      pre {
        !Domains.isDeprecated(nameHash: domain.nameHash, domainId: domain.id) : "Domain already deprecated ..."
      }
      // When domain name longer than 10, the price will set by 10 price
      var len = domain.name.length
      if len > 10 {
        len = 10
      }
      let price = self.getPrices()[len]

      if domain.parent != self.name {
        panic("domain not root domain's sub domain")
      }
      if duration < self.minRentDuration {
        panic("Duration must greater than min rent duration ".concat(self.minRentDuration.toString()))
      }
     
      if price == 0.0 || price == nil {
        panic("Can not renew domain, rent price not set yet")
      }
      
      // Calc rent price
      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance
      
      // check the rent fee
      if rentFee < rentPrice {
        panic("Not enough fee to renew your domain.")
      }
      var feeVault: @{FungibleToken.Vault}? <- nil
      // distribution of commission
      if self.commissionRate > 0.0 && refer != nil {
        feeVault <-! self._distributeCommission(feeTokens: <- feeTokens, refer: refer!, from: Domains.getRecords(domain.nameHash))
      } else {
        feeVault <-! feeTokens
      }

      // Receive rent fee
      self.domainVault.deposit(from: <- feeVault!)

      let expiredAt = Domains.getExpiredTime(domain.nameHash)! + UFix64(duration)
      // Update domain's expire time with Domains expired mapping
      Domains.updateExpired(nameHash: domain.nameHash, time: expiredAt )

      emit RenewDomain(name: domain.name, nameHash: domain.nameHash, duration: duration, price: rentFee )

    }

    // Register domain
    access(all) fun registerDomain(name: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, receiver: Capability<&{NonFungibleToken.Receiver}>, refer: Address? ){
      pre {
        self.server != nil : "Your client has not been linked to the server"
        name.length <= self.maxDomainLength : "Domain name can not exceed max length: ".concat(self.maxDomainLength.toString())
      }

      let nameHash = Flowns.getDomainNameHash(name: name, parentNameHash: self.nameHash)
    
      if Flowns.available(nameHash: nameHash) == false {
        panic("Domain not available")
      }

      // same as renew domain
      var len = name.length
      if len > 10 {
        len = 10
      }

      let price = self.getPrices()[len]
      // limit the register and renew time longer than one year

      if duration < self.minRentDuration {
        panic("Duration must geater than min rent duration, expect: ".concat(self.minRentDuration.toString()))
      }
      if price == 0.0 || price == nil {
        panic("Can not register domain, rent price not set yet")
      }

      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance

      if rentFee < rentPrice {
         panic("Not enough fee to rent your domain, expect: ".concat(rentPrice.toString()))
      }

      let expiredTime = getCurrentBlock().timestamp + UFix64(duration)

      var feeVault: @{FungibleToken.Vault}? <- nil
      // distribution of commission
      if self.commissionRate > 0.0 && refer != nil {
        feeVault <-! self._distributeCommission(feeTokens: <- feeTokens, refer: refer!, from: Domains.getRecords(nameHash))
      } else {
        feeVault <-! feeTokens
      }

      self.domainVault.deposit(from: <- feeVault!)

      self.server!.borrow()!.mintDomain(name: name, nameHash: nameHash, parentName: self.name, expiredAt: expiredTime, receiver: receiver)

      self.domainCount = self.domainCount + (1 as UInt64)

    }

    // Withdraw vault fee 
    access(account) fun withdrawVault(receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      let vault = receiver.borrow()!
      vault.deposit(from: <- self.domainVault.withdraw(amount: amount))
      
      emit RootDomainVaultWithdrawn(name: self.name, amount: amount)
    }

    access(account) fun changeRootDomainVault(vault: @{FungibleToken.Vault}) {

      let balance = self.getVaultBalance()

      if balance > 0.0 {
        panic("Please withdraw the balance of the previous vault first ")
      }

      let preVault <- self.domainVault <- vault
      
      destroy preVault
      // clean the price
      self.prices = {}
      emit RootDomainVaultChanged()
    }

  }


  // Root domain public interface for fns user
  access(all) resource interface RootDomainCollectionPublic {

    access(all) fun getDomainInfo(domainId: UInt64) : RootDomainInfo

    access(all) fun getAllDomains(): {UInt64: RootDomainInfo}

    access(all) fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?)

    access(all) fun renewDomainWithNameHash(nameHash: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?)

    access(all) fun registerDomain(domainId: UInt64, name: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, receiver: Capability<&{NonFungibleToken.Receiver}>,  refer: Address? )

    access(all) fun getPrices(domainId: UInt64): {Int: UFix64}

    access(all) fun getVaultBalance(domainId: UInt64): UFix64

  }

  // Manager resource
  access(all) resource interface RootDomainCollectionAdmin {

    access(account) fun createRootDomain(
      name: String, 
      vault: @{FungibleToken.Vault}
    )

    access(account) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64)

    access(account) fun changeRootDomainVault(domainId: UInt64, vault: @{FungibleToken.Vault})

    access(account) fun setPrices(domainId: UInt64, len: Int, price: UFix64)

    access(account) fun setMinRentDuration(domainId: UInt64, duration: UFix64)

    access(account) fun setMaxDomainLength(domainId: UInt64, length: Int)

    access(account) fun setCommissionRate(domainId: UInt64, rate: UFix64)
    
    access(account) fun mintDomain(domainId: UInt64, name: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)

    access(account) fun renewDomainWithAdmin(nameHash: String, duration: UFix64)

  }

  // Root domain Collection 
  access(all) resource RootDomainCollection: RootDomainCollectionPublic, RootDomainCollectionAdmin {
    // Root domains
    access(account) var domains: @{UInt64: RootDomain}

    init(
    ) {
      self.domains <- {}
    }

    // Create root domain
    access(account) fun createRootDomain(
      name: String, 
      vault: @{FungibleToken.Vault}
    ) {
      
      let nameHash = Flowns.hash(node:"", lable: name)
      let prefix = "0x"

      let rootDomain  <- create RootDomain(
        id: Flowns.totalRootDomains,
        name: name,
        nameHash: prefix.concat(nameHash),
        vault: <- vault
      )

      Flowns.totalRootDomains = Flowns.totalRootDomains + 1 as UInt64
      emit RootDomainCreated(name: name, nameHash: nameHash,  id: rootDomain.id)

      let oldDomain <- self.domains[rootDomain.id] <- rootDomain
      destroy oldDomain
    }

    access(all) fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?) {
      pre {
          self.domains[domainId] != nil : "Root domain not exist..."
        }
      let root = self.getRootDomain(domainId)
      root.renewDomain(domain: domain, duration: duration, feeTokens: <- feeTokens, refer: refer)
    }

    access(all) fun renewDomainWithNameHash(nameHash: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?) {
      let domain = Flowns.getDomain(nameHash: nameHash) ?? panic("Can not find domain by nameHash")
      // get all domains with access(all)
      let rootDomains = Flowns.getAllRootDomains()!
      let ids = rootDomains.keys
      var rootDomain: RootDomainInfo? = nil
      for id in ids {
        let root = rootDomains[id]!
        if root.name == domain.parent {
          rootDomain = root
        }
      }
      assert(rootDomain != nil, message: "Can not get root domain info")

      var len = domain.name.length
      if len > 10 {
        len = 10
      }
      let price = rootDomain!.prices[len]
      
      if duration < rootDomain!.minRentDuration {
        panic("Duration must greater than min rent duration ".concat(rootDomain!.minRentDuration.toString()))
      }
      if price == 0.0 || price == nil {
        panic("Can not renew domain, rent price not set yet")
      }
      // Calc rent price
      let rentPrice = price! * duration 
      
      let rentFee = feeTokens.balance
      
      // check the rent fee
      if rentFee < rentPrice {
        panic("Not enough fee to renew your domain.")
      }

      let rootDomainRef = self.getRootDomain(rootDomain!.id)!

      var feeVault: @{FungibleToken.Vault}? <- nil
      // distribution of commission
     if rootDomain!.commissionRate > 0.0 && refer != nil {
        feeVault <-! rootDomainRef._distributeCommission(feeTokens: <- feeTokens, refer: refer!, from: Domains.getRecords(nameHash) )
      } else {
        feeVault <-! feeTokens
      }


      rootDomainRef.depositVault(fee: <- feeVault!)

      let expiredAt = Domains.getExpiredTime(nameHash)! + UFix64(duration)
      Domains.updateExpired(nameHash: nameHash, time: expiredAt )
      emit RenewDomain(name: domain.name, nameHash: domain.nameHash, duration: duration, price: rentFee )
    }


    access(all) fun registerDomain(domainId: UInt64, name: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, receiver: Capability<&{NonFungibleToken.Receiver}>, refer: Address?) {
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let root = self.getRootDomain(domainId)
      root.registerDomain(name: name, duration: duration, feeTokens: <-feeTokens, receiver: receiver, refer: refer )
    }

    access(all) fun getVaultBalance(domainId: UInt64): UFix64 {
        pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let rootRef = &self.domains[domainId] as &RootDomain?

      return rootRef!.getVaultBalance()
    }

    access(account) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      self.getRootDomain(domainId).withdrawVault(receiver: receiver, amount: amount)
    }

    access(account) fun changeRootDomainVault(domainId: UInt64, vault: @{FungibleToken.Vault}) {
      pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      self.getRootDomain(domainId).changeRootDomainVault(vault: <- vault)
    }

    access(account) fun mintDomain(domainId: UInt64, name: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>) {
        pre {
        self.domains[domainId] != nil : "Root domain not exist..."
      }
      let root = self.getRootDomain(domainId)
      root.mintDomain(name: name, duration: duration, receiver: receiver)
    }

    // Get all root domains
    access(all) fun getAllDomains(): {UInt64: RootDomainInfo} {
      var domainInfos: {UInt64: RootDomainInfo }= {}
      for id in self.domains.keys {
        let itemRef = &self.domains[id] as &RootDomain?
        domainInfos[id] = itemRef!.getRootDomainInfo()
      }
      return domainInfos
    }
    
    access(account) fun setPrices(domainId: UInt64, len: Int, price: UFix64){
      self.getRootDomain(domainId).setPrices(key: len, price: price)
    }

    access(account) fun setMinRentDuration(domainId: UInt64, duration: UFix64){
      pre {
        duration >= 604800.00 : "Duration must be greater than one week"
      }
      self.getRootDomain(domainId).setMinRentDuration(duration)
    }

    access(account) fun setMaxDomainLength(domainId: UInt64, length: Int){
      pre {
        length > 0 && length < 50 : "Domain length must greater than 0 and smaller than 50"
      }
      self.getRootDomain(domainId).setMaxDomainLength(length)
    }

    access(account) fun setCommissionRate(domainId: UInt64, rate: UFix64){
      pre {
        rate >= 0.0 && rate <= 1.0 : "Commission rate not valid"
      }
      self.getRootDomain(domainId).setCommissionRate(rate)
    }

    // get domain reference
    access(contract) fun getRootDomain(_ domainId: UInt64) : &RootDomain {
      pre {
        self.domains[domainId] != nil: "domain doesn't exist"
      }
      return (&self.domains[domainId] as &RootDomain?)!
    }
    // get Root domain info
    access(all) fun getDomainInfo(domainId: UInt64): RootDomainInfo {
      return self.getRootDomain(domainId).getRootDomainInfo()
    }

    // Query root domain's rent price
    access(all) fun getPrices(domainId: UInt64): {Int: UFix64} {
      return self.getRootDomain(domainId).getPrices()
    }

    // renew domain by nameHash with admin auth
    access(account) fun renewDomainWithAdmin(nameHash: String, duration: UFix64) {
      // pre{
      //   Domains.getExpiredTime(nameHash) != nil : "Domain doesn't exist"
      // }
      assert(Domains.getExpiredTime(nameHash) != nil, message: "Can not find owner")
      let expiredAt = Domains.getExpiredTime(nameHash)! + UFix64(duration)
      // Update domain's expire time with Domains expired mapping
      Domains.updateExpired(nameHash: nameHash, time: expiredAt )
      let domain = Flowns.getDomain(nameHash: nameHash)!
      emit RenewDomain(name: domain.name.concat(".").concat(domain.parent), nameHash: nameHash, duration: duration, price: 0.0 )
    }

  }

  // Admin interface resource
  access(all) resource interface AdminPrivate {

    access(all) fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>)

    access(all) fun addRootDomainCapability(domainId: UInt64, cap: Capability<&Domains.Collection>)

    access(all) fun createRootDomain(name: String, vault: @{FungibleToken.Vault})

    access(all) fun setRentPrice(domainId: UInt64, len: Int, price: UFix64)

    access(all) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64)

    access(all) fun changeRootDomainVault(domainId: UInt64, vault: @{FungibleToken.Vault})
    
    access(all) fun mintDomain(domainId: UInt64, name: String, duration: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)

    access(all) fun setMinRentDuration(domainId: UInt64, duration: UFix64)

    access(all) fun setMaxDomainLength(domainId: UInt64, length: Int)

    access(all) fun setCommissionRate(domainId: UInt64, rate: UFix64)

    access(all) fun setDomainForbidChars(_ chars: String)

    access(all) fun setPause(_ flag: Bool)

    access(all) fun updateFTWhitelist(key: String, flag: Bool)

    access(all) fun updateNFTWhitelist(key: String, flag: Bool)

    access(all) fun setFTWhitelist(_ val: {String: Bool})

    access(all) fun setNFTWhitelist(_ val: {String: Bool})

  }


  access(all) resource Admin: AdminPrivate {

    access(self) var server: Capability<&Flowns.RootDomainCollection>?

    init() {
      // Server is the root collection for manager to create and store root domain
      self.server = nil
    }

    // init RootDomainCollection for admin
    access(all) fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>) {
      pre {
        cap.check() : "Invalid server capablity"
        self.server == nil : "Server already set"
      }
        self.server = cap
    }

    // init Root domain's Domains collection to create collection for domain register 
    access(all) fun addRootDomainCapability(domainId: UInt64, cap: Capability<&Domains.Collection>) {
      pre {
          cap.check() : "Invalid server capablity"
      }
      self.server!.borrow()!.getRootDomain(domainId).addCapability(cap)
    }

    // Create root domain with admin
    access(all) fun createRootDomain(name: String, vault: @{FungibleToken.Vault}) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.createRootDomain(name: name, vault: <- vault)
    }

    // Set rent price
    access(all) fun setRentPrice(domainId: UInt64, len: Int, price: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.setPrices(domainId: domainId, len: len, price: price)
    }

    access(all) fun setMinRentDuration(domainId: UInt64, duration: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.setMinRentDuration(domainId: domainId, duration: duration)
    }

    access(all) fun setMaxDomainLength(domainId: UInt64, length: Int) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.setMaxDomainLength(domainId: domainId, length: length)
    }

    
    access(all) fun setCommissionRate(domainId: UInt64, rate: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.setCommissionRate(domainId: domainId, rate: rate)
    }
    
    

    // Withdraw vault 
    access(all) fun withdrawVault(domainId: UInt64, receiver: Capability<&{FungibleToken.Receiver}>, amount: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.withdrawVault(domainId: domainId, receiver: receiver, amount: amount)
    }

    // Withdraw vault 
    access(all) fun changeRootDomainVault(domainId: UInt64, vault: @{FungibleToken.Vault}) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.changeRootDomainVault(domainId: domainId, vault: <- vault)
    }

    // Mint domain with root domain
    access(all) fun mintDomain(domainId: UInt64, name: String, duration: UFix64,receiver: Capability<&{NonFungibleToken.Receiver}>) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }

      self.server!.borrow()!.mintDomain(domainId: domainId, name: name, duration: duration, receiver: receiver)
    }

      // Renew domain with admin auth
    access(all) fun renewDomain(nameHash: String, duration: UFix64) {
      pre {
        self.server != nil : "Your client has not been linked to the server"
      }
      self.server!.borrow()!.renewDomainWithAdmin(nameHash: nameHash, duration: duration)
    }

    access(all) fun setPause(_ flag: Bool) {
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

    access(all) fun setDomainForbidChars(_ chars: String) {
      let oldChars = Flowns.forbidChars
      Flowns.forbidChars = chars
      
      emit FlownsForbidCharsUpdated(before: oldChars, after: chars)
    }

    access(all) fun updateFTWhitelist(key: String, flag: Bool) {
      FNSConfig.updateFTWhitelist(key: key, flag: flag)
    }

    access(all) fun updateNFTWhitelist(key: String, flag: Bool) {
      FNSConfig.updateNFTWhitelist(key: key, flag: flag)
    }

    access(all) fun setFTWhitelist(_ val: {String: Bool}) {
      FNSConfig.setFTWhitelist(val)
    }

    access(all) fun setNFTWhitelist(_ val: {String: Bool}) {
      FNSConfig.setNFTWhitelist(val)
    }



  }

  // Create admin resource
  access(self) fun createAdminClient(): @Admin {
    emit FlownsAdminCreated()
    return <- create Admin()
  }

  access(all) fun getDomainNameHash(name: String, parentNameHash: String): String {
    
    let prefix = "0x"
    let forbidenChars: [UInt8] = Flowns.forbidChars.utf8
    let nameASCII = name.utf8

    for char in forbidenChars {
      if nameASCII.contains(char) {
        panic("Domain name illegal ...")
      }
    }

    let domainNameHash = Flowns.hash(node: parentNameHash.slice(from: 2, upTo: 66), lable:name )
    return prefix.concat(domainNameHash)
  }

  // calc hash with node and lable
  access(all) fun hash(node: String, lable: String): String {
    var prefixNode = node
    if node.length == 0 {
      prefixNode = "0000000000000000000000000000000000000000000000000000000000000000"
    }
    let lableHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(lable.utf8))
    let hash = String.encodeHex(HashAlgorithm.SHA3_256.hash(prefixNode.concat(lableHash).utf8))
    return hash
  }

  // query domain info by nameHash
  access(all) fun getDomain(nameHash: String): &Domains.NFT? {
    let address = Domains.getRecords(nameHash) ?? panic("Domain not exist")
    let account = getAccount(address)
    let collection = account.capabilities.borrow<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)!
    // let collection = collectionCap.borrow()!
    var domain: &Domains.NFT? = nil

    let id = Domains.getDomainId(nameHash)
    domain = collection.borrowDomain(id: id!)
    return domain
  }


  // Query root domain
  access(all) fun getRootDomainInfo(domainId: UInt64): RootDomainInfo? {
    let account = Flowns.account
    let collection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    if collection != nil {
      return collection!.getDomainInfo(domainId: domainId)
    }
    return nil
  }
  // Query all root domain
  access(all) fun getAllRootDomains(): {UInt64: RootDomainInfo}? {

    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    if rootCollection != nil  {
        return rootCollection!.getAllDomains()
    }
    return nil
  }
  
  // Check domain available 
  access(all) fun available(nameHash: String): Bool {

    if Domains.getRecords(nameHash) == nil {
      return true
    }
    return Domains.isExpired(nameHash)
  }

  access(all) fun getRentPrices(domainId: UInt64): {Int: UFix64} {

    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    if rootCollection != nil  {
      return rootCollection!.getPrices(domainId: domainId)
    }
    return {}
  }

  access(all) fun getRootVaultBalance(domainId: UInt64): UFix64 {

    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    // let collection = rootCollectionCap.borrow()?? panic("Could not borrow collection ")
    let balance = rootCollection!.getVaultBalance(domainId: domainId)
    return balance
  }

  access(all) fun registerDomain(domainId: UInt64, name: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, receiver: Capability<&{NonFungibleToken.Receiver}>, refer: Address? ){
    pre {
      Flowns.isPause == false : "Register pause"
    }
    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    // let collection = rootCollectionCap.borrow() ?? panic("Could not borrow collection ")
    rootCollection!.registerDomain(domainId: domainId, name: name, duration: duration, feeTokens: <-feeTokens, receiver: receiver, refer: refer)
  }
  
  access(all) fun renewDomain(domainId: UInt64, domain: &Domains.NFT, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?) {
    pre {
      Flowns.isPause == false : "Renewer pause"
    }
    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    // let collection = rootCollectionCap.borrow() ?? panic("Could not borrow collection ")
    rootCollection!.renewDomain(domainId: domainId, domain: domain, duration: duration, feeTokens: <-feeTokens, refer: refer)
  }

  access(all) fun renewDomainWithNameHash(nameHash: String, duration: UFix64, feeTokens: @{FungibleToken.Vault}, refer: Address?) {
    pre {
      Flowns.isPause == false : "Renewer pause"
      duration > 0.0 : "Duration must great than 0"
    }
    
    let account = Flowns.account
    let rootCollection = account.capabilities.borrow<&{Flowns.RootDomainCollectionPublic}>(self.CollectionPublicPath)
    // let collection = rootCollectionCap.borrow() ?? panic("Could not borrow collection ")
    rootCollection!.renewDomainWithNameHash(nameHash: nameHash, duration: duration, feeTokens: <-feeTokens, refer: refer)
  }
  
  init() {

    self.CollectionPublicPath = /public/flownsCollection
    self.CollectionStoragePath = /storage/flownsCollection
    self.FlownsAdminPrivatePath = /private/flownsAdmin
    self.FlownsAdminStoragePath =/storage/flownsAdmin

    let account = self.account
    let admin <- Flowns.createAdminClient()

    account.storage.save<@Flowns.Admin>(<-admin, to: self.FlownsAdminStoragePath)

    self.totalRootDomains = 0
    self.isPause = true
    self.forbidChars = "!@#$%^&*()<>? ./ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    let collection: @Flowns.RootDomainCollection <- create RootDomainCollection()

    account.storage.save(<-collection, to: Flowns.CollectionStoragePath)
  }
}
 