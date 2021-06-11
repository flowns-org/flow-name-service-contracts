
import FungibleToken from "./standard/FungibleToken.cdc"
import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import SubDomain from "./SubDomain.cdc"

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
  pub event RootDomainDestroyed(domainId:UInt64)

  pub event RootDomainCreated(domainName:String, domainId: UInt64)

  pub event registryChanged(registryName:String, registryPath:String)


  // structs
  pub struct RootDomainInfo {
    pub let domainId: UInt64
    pub let owner: Address
    pub let name: String
    pub let nameHash: String
    pub let subDomainCount: Fix64
    pub let domainRegistry: String //todo registry info
  }



  // resources
  pub resource RootDomain {
    pub let id: UInt64

    pub let name:String

    pub let nameHash:String

    pub let subDomainCount:UInt64

    pub let owner:Address

    priv let DomainVault: @FungibleToken.Vault

    pub var domainRegistry: Capability<&{Registry.Regigter}> // TODO

    pub var subDomains: @{String: SubDomain}
    
    // sub domain
    access(contract) var subDomainCapability: Capability<&SubDomain.Collection>

    init(id:UInt64, name:String, nameHash:String, subDomainCap:Capability<&SubDomain.Collection>, vaultCap: Capability<&{FungibleToken.Receiver}>){
      self.id = id
      self.name = name
      self.nameHash = nameHash // TODO 
      self.owner = Flowns.account
      self.subDomainCount = 0
      self.domainVault <- FlowToken.createEmptyVault()
      self.domainRegistry = nil
      self.subDomains = {}
    }

    // set registry
    access(account) fun setRegistry(registry:Capability<&{Registry.Regigter}>){
      self.domainRegistry = registry
      emit registryChanged(registryName: registry.name, registryPath: registry.path)
    }

     pub fun getDomainInfo() : RootDomainInfo {
       // wip
     }


    destroy(){
        log("Destroy Root domains")
        destroy self.subDomainCapability
        destroy self.domainVault
        emit RootDomainDestroyed(domainId: self.id)
    }

  }



    pub resource interface DomainPublic {

        pub fun getDomainInfo(domainId: UInt64) : RootDomainInfo

        pub fun getAllDomains(): {UInt64: RootDomainInfo}

        // TODO register sub domain
    }

  pub resource interface DomainAdmin {

      pub fun createRootDomain(
          id: UInt64,
          name: String, 
          nameHash: String,
          subDomainCap: Capability<&SubDomain.Collection>,
          vaultCap: Capability<&{FungibleToken.Receiver}>,
          )

  }

pub resource RootDomainCollection: DomainPublic, DomainAdmin {

        pub var domains: @{UInt64: RootDomain}

        init(
        ) {
          self.domains <- {}
        }

        // When creating a drop you send in an NFT and the number of editions you want to sell vs the unique one
        // There will then be minted edition number of extra copies and put into the editions auction
        pub fun createRootDomain(
            id: UInt64,
            name: String, 
            nameHash: String,
            subDomainCap: Capability<&SubDomain.Collection>,
            vaultCap: Capability<&{FungibleToken.Receiver}>
            ) {

            pre {
                vaultCap.check() == true : "Vault capability should exist"
            }

             let rootDomain  <- create RootDomain(
               id: Flowns.totalRootDomains,
               name:name,
               nameHash:name,
               subDomainCap <- subDomainCap // todo: create subdomain
               )

            emit RootDomainCreated(name: name, domainId: rootDomain.id)

            let oldDomain <- self.domains[rootDomain.id] <- rootDomain
            destroy oldDomain

        }

        // TODO
        access(account) fun withdraw(){

        }

        //Get all the drop statuses
        pub fun getAllDomains(): {UInt64: RootDomainInfo} {
            var domainInfos: {UInt64: RootDomainInfo }= {}
            for id in self.domians.keys {
                let itemRef = &self.domians[id] as? &RootDomain
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
           self.server!.borrow()!.withdraw(dropId)
        }

       
        pub fun createRootDomain(
          
          vaultCap: Capability<&{FungibleToken.Receiver}>)  {

          pre {
              self.server != nil : "Your client has not been linked to the server"
          }

          // TODO self.server!.borrow()!.createRootDomain()
        }
    

        pub fun editionArt(art: &Art.NFT, edition: UInt64, maxEdition: UInt64) : @Art.NFT {
            return <- Art.makeEdition(original: art, edition: edition, maxEdition: maxEdition)
        }

        pub fun getFlowWallet():&FungibleToken.Vault {
          pre {
            self.server != nil : "Your client has not been linked to the server"
          }
          return Flowns.account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)!
        }


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