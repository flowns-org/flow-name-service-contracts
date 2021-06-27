
import FungibleToken from "./standard/FungibleToken.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import Domain from "./Domain.cdc"
import FlowToken from "./standard/FlowToken.cdc"


/*
  The main contract in the Flow Name Service.
 */
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

    pub let domainCount:UInt64

    priv let domainVault: @FungibleToken.Vault

    pub var domains: @{String: Address}

    pub var expires: {String: UInt64}

    pub var prices:{UInt64: UFix64}
    
    // sub domain refs
    // access(contract) var domainCapability: Capability<&Domain.Collection>

    init(id:UInt64, name:String, nameHash:String){
      self.id = id
      self.name = name
      self.nameHash = nameHash // TODO 
      self.domainCount = 0
      self.domainVault <- FlowToken.createEmptyVault()
      self.domains <- {}
      self.expires = {}
      self.prices = {}
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

    access(contract) mintDomain(id: UInt64, name:String, nameHash:String, duration: UFix64, receiver: Capability<&{FungibleToken.Receiver}>){

      Flowns.totalRootDomains = Flowns.totalRootDomains + UInt64(1)
      let domain <- create Domain.Domain(
        id: id,
        name: name,
        nameHash: nameHash,
        parent: self.name
      )
      let expiredTime = getCurrentBlock().timestamp + UFix64(duration)
      domain.expiredAt = expiredTime
      self.expires[domainCap.nameHash] = expiredTime
      self.domains[nameHash] = receiver.addreses
      self.domainCount = self.domainCount + UInt64(1)
      receiver.deposit(token: <- domain)

    }
    

    pub fun setPrices(_ key:UInt64, price: UFix64) {
      self.prices[key]= price
      // emit
    }



    pub fun renewDomain(domainCap: Capability<&{Domain.Domain}>, duration: UFix64, feeTokens: @FungibleToken.Vault) {
      pre {
        self.prices[domainCap.name.length] != nil : "Cannot get rent price for your domain."
      }
      let length = domainCap.name.length
      let price = self.prices[length]
      if duration < 3153600 {
        panic("duration must geater than 3153600 ")
      }
      if price == 0 {
        panic("Can not renew domain")
      }

      // let expiredAt = domainCap.expiredAt
      // let currentTimestamp = getCurrentBlock().timestamp
      let rentPrice = price * duration 
      
      let rentFee = feeTokens.balance

      if rentFee < rentPrice {
         panic("Not enough fee to renew your domain.")
      }

      self.domainVault.deposit(from: <- feeTokens)
      let expiredTime = domainCap.expiredAt + UFix64(duration)
      domainCap.expiredAt = expiredTime
      self.expires[domainCap.nameHash] = expiredTime

      emit RenewDomain(name:domainCap.name, duration: duration, price: rentfee )

    }

    pub fun registerDomain(name:string, nameHash:String, duration:UFix64, feeTokens: @FungibleToken.Vault, receiver: Capability<&{FungibleToken.Receiver}> ){
      if self.domains[nameHash] {
        panic("domain not available.")
      }

      // TODO add commitment
      
      let length = domainCap.name.length
      let price = self.prices[length]
      if duration < 3153600 {
        panic("duration must geater than 3153600")
      }
      if price == 0 {
        panic("Can not register domain")
      }
      self.domainVault.deposit(from: <- feeTokens)
      mintDomain(self.domainCount, name, nameHash, duration, receiver)      

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

        // TODO register sub domain

        // TODO renew sub domain
    }

  pub resource interface DomainAdmin {

      pub fun createRootDomain(
          id: UInt64,
          name: String, 
          nameHash: String,
        )
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
        id: UInt64,
        name: String, 
        nameHash: String,
        ) {

        let rootDomain  <- create RootDomain(
          id: Flowns.totalRootDomains,
          name:name,
          nameHash:name
          )

        emit RootDomainCreated(name: name, id: rootDomain.id)

        let oldDomain <- self.domains[rootDomain.id] <- rootDomain
        destroy oldDomain

      }

      // TODO 
      access(account) fun withdrawVault(){

      }

      //Get all the drop statuses
      pub fun getAllDomains(): {UInt64: RootDomainInfo} {
          var domainInfos: {UInt64: RootDomainInfo }= {}
          for id in self.domains.keys {
              let itemRef = &self.domains[id] as? &RootDomain
              domainInfos[id] = itemRef.getDomainInfo()
          }
          return domainInfos

      }

      access(contract) fun getDomain(_ domainId:UInt64) : &RootDomain {
          pre {
              self.domains[domainId] != nil:
                  "domain doesn't exist"
          }
          return &self.domains[domainId] as &RootDomain
      }

      pub fun getDomainInfo(domainId:UInt64): RootDomainInfo {
          return self.getDomain(domainId).getDomainInfo()
      }


      destroy() {            
          destroy self.domains
      }
    }

    //
    pub resource interface AdminPublic {
        pub fun addCapability(_ cap: Capability<&Flowns.RootDomainCollection>)
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

        // withdraw vault balance
        pub fun withdraw(_ domainId: UInt64) {
          pre {
            self.server != nil : "Your client has not been linked to the server"
          }
          self.server!.borrow()!.withdraw()
        }

      
        pub fun createRootDomain(
          id: UInt64,
          name: String, 
          nameHash: String
          ) {
          pre {
              self.server != nil : "Your client has not been linked to the server"
          }
          self.server!.borrow()!.createRootDomain(id, name, nameHash)
        }
    

        pub fun mintDomain(
          rootId: UInt64,
          name: String, 
          nameHash: String,
          duration: UInt64,
          account: Address
          ) {
          pre {
              self.server != nil : "Your collection has not been linked to the server"
          }
          let rootRef = self.server!.borrow()!.domains[rootId].borrow()!
          let receiver = getAccount(account)
        .getCapability(Domain.CollectionPublicPath)
        .borrow<&NonFungibleToken.Receiver>()
        ?? panic("Could not borrow Balance reference to the Vault")
          rootRef.mintDomain(rootRef.domainCount ,name, nameHash, duration, receiver)
        }

        

        // pub fun getFlowWallet():&FungibleToken.Vault {
        //   pre {
        //     self.server != nil : "Your client has not been linked to the server"
        //   }
        //   return Flowns.account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)!
        // }

    }

 //make it possible for a user that wants to be a versus admin to create the client
    pub fun createAdminClient(): @Admin {
        return <- create Admin()
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