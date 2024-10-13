import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
import MetadataViews from "./standard/MetadataViews.cdc"
import ViewResolver from "./standard/ViewResolver.cdc"
import FNSConfig from "./FNSConfig.cdc"

// Domains define the domain and sub domain resource
// Use records and expired to store domain's owner and expiredTime
access(all) contract Domains: NonFungibleToken {
  // Sum the domain number with domain and subdomain
  access(all) var totalSupply: UInt64

  // Paths
  access(all) let CollectionStoragePath: StoragePath
  access(all) let CollectionPublicPath: PublicPath

  // Domain records to store the owner of Domains.Domain resource
  // When domain resource transfer to another user, the records will be update in the deposit func
  access(self) let records: {String: Address}

  // Expired records for Domains to check the domain's validity, will change at register and renew
  access(self) let expired: {String: UFix64}

  // Store the expired and deprecated domain records 
  access(self) let deprecated: {String: {UInt64: DomainDeprecatedInfo}}

  // Store the domains id with namehash key
  access(self) let idMap: {String: UInt64}


  access(all) let domainExpiredTip: String
  access(all) let domainDeprecatedTip: String


  // Events
  access(all) event ContractInitialized()
  access(all) event Withdraw(id: UInt64, from: Address?)
  access(all) event Deposit(id: UInt64, to: Address?)
  access(all) event Created(id: UInt64, name: String)
  access(all) event DomainRecordChanged(name: String, resolver: Address)
  access(all) event DomainExpiredChanged(name: String, expiredAt: UFix64)
  access(all) event SubDomainCreated(id: UInt64, hash: String)
  access(all) event SubDomainRemoved(id: UInt64, hash: String)
  access(all) event SubdmoainTextChanged(nameHash: String, key: String, value: String)
  access(all) event SubdmoainTextRemoved(nameHash: String, key: String)
  access(all) event SubdmoainAddressChanged(nameHash: String, chainType: UInt64, address: String)
  access(all) event SubdmoainAddressRemoved(nameHash: String, chainType: UInt64)
  access(all) event DmoainAddressRemoved(nameHash: String, chainType: UInt64)
  access(all) event DmoainTextRemoved(nameHash: String, key: String)
  access(all) event DmoainAddressChanged(nameHash: String, chainType: UInt64, address: String)
  access(all) event DmoainTextChanged(nameHash: String, key: String, value: String)
  access(all) event DomainMinted(id: UInt64, name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Address)
  access(all) event DomainVaultDeposited(nameHash: String, vaultType: String, amount: UFix64, from: Address?)
  access(all) event DomainVaultWithdrawn(nameHash: String, vaultType: String, amount: UFix64, from: Address?)
  access(all) event DomainCollectionAdded(nameHash: String, collectionType: String)
  access(all) event DomainCollectionWithdrawn(nameHash: String, collectionType: String, itemId: UInt64, from: Address?)
  access(all) event DomainCollectionDeposited(nameHash: String, collectionType: String, itemId: UInt64, from: Address?)
  access(all) event DomainReceiveOpened(name: String)
  access(all) event DomainReceiveClosed(name: String)



  access(all) struct DomainDeprecatedInfo {
    access(all) let id: UInt64
    access(all) let owner: Address
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let parentName: String
    access(all) let deprecatedAt: UFix64
    access(all) let trigger: Address


     init(
      id: UInt64,
      owner: Address,
      name: String,
      nameHash: String, 
      parentName: String,
      deprecatedAt: UFix64,
      trigger: Address
    ) {
      self.id = id
      self.owner = owner
      self.name = name
      self.nameHash = nameHash
      self.parentName = parentName
      self.deprecatedAt = deprecatedAt
      self.trigger = trigger
    }   
  }

  // Subdomain detail
  access(all) struct SubdomainDetail {
    access(all) let id: UInt64
    access(all) let owner: Address
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let addresses: {UInt64: String}
    access(all) let texts: {String: String}
    access(all) let parentName: String
    access(all) let createdAt: UFix64 

    
    init(
      id: UInt64,
      owner: Address,
      name: String,
      nameHash: String, 
      addresses:{UInt64: String},
      texts: {String: String},
      parentName: String,
      createdAt: UFix64
    ) {
      self.id = id
      self.owner = owner
      self.name = name
      self.nameHash = nameHash
      self.addresses = addresses
      self.texts = texts
      self.parentName = parentName
      self.createdAt = createdAt
    }   
  }
  
  // Domain detail
  access(all) struct DomainDetail {
    access(all) let id: UInt64
    access(all) let owner: Address
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let expiredAt: UFix64
    access(all) let addresses: {UInt64: String}
    access(all) let texts: {String: String}
    access(all) let parentName: String
    access(all) let subdomainCount: UInt64
    access(all) let subdomains: {String: SubdomainDetail}
    access(all) let createdAt: UFix64 
    access(all) let vaultBalances: {String: UFix64}
    access(all) let collections: {String: [UInt64]}
    access(all) let receivable: Bool
    access(all) let deprecated: Bool


    init(
      id: UInt64,
      owner: Address,
      name: String,
      nameHash: String, 
      expiredAt: UFix64,
      addresses: {UInt64: String},
      texts: {String: String},
      parentName: String,
      subdomainCount: UInt64,
      subdomains: {String: SubdomainDetail},
      createdAt: UFix64,
      vaultBalances: {String: UFix64},
      collections: {String: [UInt64]},
      receivable: Bool,
      deprecated: Bool
    ) {
      self.id = id
      self.owner = owner
      self.name = name
      self.nameHash = nameHash
      self.expiredAt = expiredAt
      self.addresses = addresses
      self.texts = texts
      self.parentName = parentName
      self.subdomainCount = subdomainCount
      self.subdomains = subdomains
      self.createdAt = createdAt
      self.vaultBalances = vaultBalances
      self.collections = collections
      self.receivable = receivable
      self.deprecated = deprecated
    } 
  }

  access(all) resource interface DomainPublic {

    access(all) let id: UInt64
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let parent: String
    access(all) var receivable: Bool
    access(all) let createdAt: UFix64
   

    access(all) fun getText(key: String): String?

    access(all) fun getAddress(chainType: UInt64): String?

    access(all) fun getAllTexts():{String: String}

    access(all) fun getAllAddresses():{UInt64: String}

    access(all) fun getDomainName(): String

    access(all) fun getDetail(): DomainDetail

    access(all) fun getSubdomainsDetail(): [SubdomainDetail]

    access(all) fun getSubdomainDetail(nameHash: String): SubdomainDetail

    access(all) fun depositVault(from: @{FungibleToken.Vault}, senderRef: &{FungibleToken.Receiver}?)

    access(all) fun addCollection(collection: @{NonFungibleToken.Collection})

    access(all) fun checkCollection(key: String): Bool

    access(all) fun depositNFT(key: String, token: @{NonFungibleToken.NFT}, senderRef: &{NonFungibleToken.CollectionPublic}?)
  }

  access(all) resource interface SubdomainPublic {
    
    access(all) let id: UInt64
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let parent: String
    access(all) let createdAt: UFix64 


    access(all) fun getText(key: String): String?

    access(all) fun getAddress(chainType: UInt64): String?

    access(all) fun getAllTexts():{String: String}

    access(all) fun getAllAddresses():{UInt64: String}

    access(all) fun getDomainName(): String

    access(all) fun getDetail(): SubdomainDetail
  }

  access(all) resource interface SubdomainPrivate {

    access(all) fun setText(key: String, value: String)

    access(all) fun setAddress(chainType: UInt64, address: String)

    access(all) fun removeText(key: String)

    access(all) fun removeAddress(chainType: UInt64)
  }

  // Domain private for Domain resource owner manage domain and subdomain
  access(all) resource interface DomainPrivate {

    access(all) fun setText(key: String, value: String)

    access(all) fun setAddress(chainType: UInt64, address: String)

    access(all) fun setETHAddress(address: String, publicKey: [UInt8], signature: [UInt8])

    access(all) fun removeText(key: String)

    access(all) fun removeAddress(chainType: UInt64)

    access(all) fun createSubDomain(name: String)

    access(all) fun removeSubDomain(nameHash: String)

    access(all) fun setSubdomainText(nameHash: String, key: String, value: String)

    access(all) fun setSubdomainAddress(nameHash: String, chainType: UInt64, address: String)

    access(all) fun removeSubdomainText(nameHash: String, key: String)

    access(all) fun removeSubdomainAddress(nameHash: String, chainType: UInt64)

    access(all) fun withdrawVault(key: String, amount: UFix64): @{FungibleToken.Vault}

    access(all) fun withdrawNFT(key: String, itemId: UInt64): @{NonFungibleToken.NFT} 

    access(all) fun setReceivable(_ flag: Bool)

  }

  // Subdomain resource belongs Domain.NFT
  access(all) resource Subdomain: SubdomainPublic, SubdomainPrivate {

    access(all) let id: UInt64
    access(all) let name: String
    access(all) let nameHash: String
    access(all) let parent: String
    access(all) let parentNameHash: String
    access(all) let createdAt: UFix64
    access(self) let addresses:  {UInt64: String}
    access(self) let texts: {String: String} 


    init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.addresses = {}
      self.texts ={}
      self.parent = parent
      self.parentNameHash = parentNameHash
      self.createdAt = getCurrentBlock().timestamp
    }

    // Get subdomain full name with parent name
    access(all) fun getDomainName(): String {
      let domainName = ""
      return domainName.concat(self.name).concat(".").concat(self.parent)
    }

    // Get subdomain property
    access(all) fun getText(key: String): String? {
      return self.texts[key]
    }

    // Get address of subdomain
    access(all) fun getAddress(chainType: UInt64): String? {
      return self.addresses[chainType]!
    }

    // get all texts
    access(all) fun getAllTexts():{String: String}{
      return self.texts
    }

    // get all texts
    access(all) fun getAllAddresses():{UInt64: String}{
      return self.addresses
    }

    // get subdomain detail
    access(all) fun getDetail(): SubdomainDetail {
      let owner = Domains.getRecords(self.parentNameHash)!

      let detail = SubdomainDetail(
        id: self.id,
        owner: owner,
        name: self.getDomainName(), 
        nameHash: self.nameHash,
        addresses: self.getAllAddresses(),
        texts: self.getAllTexts(),
        parentName: self.parent,
        createdAt: self.createdAt
      )
      return detail
    }


    access(all) fun setText(key: String, value: String){
      pre {
        !Domains.isExpired(self.parentNameHash) : Domains.domainExpiredTip
      }
      self.texts[key] = value

      emit SubdmoainTextChanged(nameHash: self.nameHash, key: key, value: value)
    }

    access(all) fun setAddress(chainType: UInt64, address: String){
      pre {
        !Domains.isExpired(self.parentNameHash) : Domains.domainExpiredTip
      }
      self.addresses[chainType] = address

      emit SubdmoainAddressChanged(nameHash: self.nameHash, chainType: chainType, address: address)

    }

    access(all) fun removeText(key: String){
      pre {
        !Domains.isExpired(self.parentNameHash) : Domains.domainExpiredTip
      }
      self.texts.remove(key: key)

      emit SubdmoainTextRemoved(nameHash: self.nameHash, key: key)

    }

    access(all) fun removeAddress(chainType: UInt64){
      pre {
        !Domains.isExpired(self.parentNameHash) : Domains.domainExpiredTip
      }
      self.addresses.remove(key: chainType)

      emit SubdmoainAddressRemoved(nameHash: self.nameHash, chainType: chainType)

    }

  }

  // Domain resource for NFT standard
  access(all) resource NFT: DomainPublic, DomainPrivate, ViewResolver.Resolver, NonFungibleToken.NFT{

    access(all) let id: UInt64
    access(all) let name: String
    access(all) let nameHash: String
    
    access(all) let createdAt: UFix64
    // parent domain name
    access(all) let parent: String
    access(all) var subdomainCount: UInt64

    access(all) var receivable: Bool

    access(self) var subdomains: @{String: Subdomain}
    access(self) let addresses:  {UInt64: String}
    access(self) let texts: {String: String}
    access(self) var vaults: @{String: {FungibleToken.Vault}}
    access(self) var collections: @{String: {NonFungibleToken.Collection}}

    init(id: UInt64, name: String, nameHash: String, parent: String) {
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.addresses = {}
      self.texts = {}
      self.subdomainCount = 0
      self.subdomains <- {}
      self.parent = parent
      self.vaults <- {}
      self.collections <- {}
      self.receivable = true
      self.createdAt = getCurrentBlock().timestamp
    }

    access(all) view fun getViews(): [Type] {
      return [
        Type<MetadataViews.Display>(),
        Type<MetadataViews.Royalties>(),
        Type<MetadataViews.Editions>(),
        Type<MetadataViews.ExternalURL>(),
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>(),
        Type<MetadataViews.Serial>(),
        Type<MetadataViews.Traits>()
      ]
    }


    access(all) fun resolveView(_ view: Type): AnyStruct? {
      let domainName = self.getDomainName()
      let dataUrl = "https://flowns.org/api/data/domain/".concat(domainName)
      let thumbnailUrl = "https://flowns.org/api/fns?domain=".concat(domainName)
      
      switch view {
        case Type<MetadataViews.Display>():
          return MetadataViews.Display(
              name: domainName,
              description: "Flowns domain ".concat(domainName),
              thumbnail: MetadataViews.HTTPFile(
                  url: thumbnailUrl
              )
          )
        case Type<MetadataViews.Editions>():
            // There is no max number of NFTs that can be minted from this contract
            // so the max edition field value is set to nil
            let editionInfo = MetadataViews.Edition(name: "Flowns Domains NFT Edition", number: self.id, max: nil)
            let editionList: [MetadataViews.Edition] = [editionInfo]
            return MetadataViews.Editions(
                editionList
            )
        case Type<MetadataViews.Serial>():
            return MetadataViews.Serial(
                self.id
            )
        case Type<MetadataViews.Royalties>():
            let receieverCap =  Domains.account.capabilities.get<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            let royalty= MetadataViews.Royalty(receiver: receieverCap, cut: 0.1, description: "Flowns will take 10% as second trade royalty fee")
            return MetadataViews.Royalties([royalty])
            
        case Type<MetadataViews.ExternalURL>():
            return MetadataViews.ExternalURL("https://flowns.org/domain/".concat(domainName))
        case Type<MetadataViews.NFTCollectionData>():
            return MetadataViews.NFTCollectionData(
                storagePath: Domains.CollectionStoragePath,
                publicPath: Domains.CollectionPublicPath,
                publicCollection: Type<&Domains.Collection>(),
                publicLinkedType: Type<&Domains.Collection>(),
                createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                    return <- Domains.createEmptyCollection(nftType: Type<@Domains.NFT>())
                })
            )
        case Type<MetadataViews.NFTCollectionDisplay>():
            let squareMedia = MetadataViews.Media(
                file: MetadataViews.HTTPFile(
                    url: "https://www.flowns.org/assets/flowns_logo_light.svg"
                ),
                mediaType: "image/svg+xml"
            )
            let banerMedia = MetadataViews.Media(
                file: MetadataViews.HTTPFile(
                    url: "https://www.flowns.org/assets/flowns_logo_light.svg"
                ),
                mediaType: "image/svg+xml"
            )
            return MetadataViews.NFTCollectionDisplay(
              name: "The Flowns domain Collection",
              description: "This collection is managed by Flowns and present the ownership of domain.",
              externalURL: MetadataViews.ExternalURL("https://flowns.org"),
              squareImage: squareMedia,
              bannerImage: banerMedia,
              socials: {
                  "twitter": MetadataViews.ExternalURL("https://twitter.com/flownsorg"),
                  "discord": MetadataViews.ExternalURL("https://discord.gg/fXz4gBaYXd"),
                  "website": MetadataViews.ExternalURL("https://flowns.org"),
                  "medium": MetadataViews.ExternalURL("https://medium.com/@Flowns")
              }
            )
        case Type<MetadataViews.Traits>():
          let excludedTraits = ["mintedTime"]
          let traitsView = MetadataViews.dictToTraits(dict: self.texts, excludedNames: excludedTraits)
          // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
          return traitsView
      }
      return nil
    }
    
    // get domain full name with root domain
    access(all) fun getDomainName(): String {
      return self.name.concat(".").concat(self.parent)
    }

    access(all) fun getText(key: String): String? {
      
      return self.texts[key]
    }

    access(all) fun getAddress(chainType: UInt64): String? {
     
      return self.addresses[chainType]!
    }

    access(all) fun getAllTexts():{String: String}{
      return self.texts
    }

    access(all) fun getAllAddresses():{UInt64: String}{
      return self.addresses
    }

    access(all) fun setText(key: String, value: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        key != "_ethSig": "`_ethSig` is reserved"
      }
      self.texts[key] = value

      emit DmoainTextChanged(nameHash: self.nameHash, key: key, value: value)
    }

    access(all) fun setAddress(chainType: UInt64, address: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }

      switch chainType {
        case 0 :
          self.addresses[chainType] = address
          emit DmoainAddressChanged(nameHash: self.nameHash, chainType: chainType, address: address)
          return
        case 1 :
          // verify domain name texts with signature
          return
        default:
          return
      }

    }

    access(all) fun setETHAddress(address: String, publicKey: [UInt8], signature: [UInt8]) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        address.length > 0 : "Cannot verify empty message"
      }

      let prefix = "\u{19}Ethereum Signed Message:\n".concat(address.length.toString())

      assert(Domains.verifySignature(message: address, messagePrefix: prefix, hashTag: nil, hashAlgorithm: HashAlgorithm.KECCAK_256, publicKey: publicKey, signatureAlgorithm: SignatureAlgorithm.ECDSA_secp256k1, signature: signature) == true, message: "Invalid signature")

      let owner = Domains.getRecords(self.nameHash)
      assert(owner != nil, message: "Can not find owner")

      if owner!.toString() == address {

        let now = getCurrentBlock().timestamp
        let ethAddr = Domains.ethPublicKeyToAddress(publicKey: publicKey)
        let verifyStr = "{".concat("\"timestamp\": \"").concat(now.toString()).concat("\", \"message\": \"").concat(address).concat("\", \"publicKey\": \"").concat(String.encodeHex(publicKey)).concat("\", \"ethAddr\": \"").concat(ethAddr).concat("\"}")

        self.texts["_ethSig"] = verifyStr

        
        self.addresses[1] = ethAddr

        emit DmoainAddressChanged(nameHash: self.nameHash, chainType: 1, address: address)
      }
    }


    access(all) fun removeText(key: String){
        pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }

      self.texts.remove(key: key)
      
      emit DmoainTextRemoved(nameHash: self.nameHash, key: key)
    }

    access(all) fun removeAddress(chainType: UInt64){
        pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }

      self.addresses.remove(key: chainType)

      emit DmoainAddressRemoved(nameHash: self.nameHash, chainType: chainType)
    }

    access(all) fun setSubdomainText(nameHash: String, key: String, value: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }

      let subdomain = (&self.subdomains[nameHash] as &Domains.Subdomain?)!
      subdomain.setText(key: key, value: value)
    }

    access(all) fun setSubdomainAddress(nameHash: String, chainType: UInt64, address: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }

      let subdomain = (&self.subdomains[nameHash] as &Domains.Subdomain?)!
      subdomain.setAddress(chainType: chainType, address: address)
    }

    access(all) fun removeSubdomainText(nameHash: String, key: String) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }
      let subdomain = (&self.subdomains[nameHash] as &Domains.Subdomain?)!
      subdomain.removeText(key: key)
    }

    access(all) fun removeSubdomainAddress(nameHash: String, chainType: UInt64) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }
      let subdomain = (&self.subdomains[nameHash] as &Domains.Subdomain?)!
      subdomain.removeAddress(chainType: chainType)
    }
    
    access(all) fun getDetail(): DomainDetail {

      let owner = Domains.getRecords(self.nameHash) ?? panic("Cannot get owner")
      let expired = Domains.getExpiredTime(self.nameHash) ?? panic("Cannot get expired time")
      
      let subdomainKeys = self.subdomains.keys
      var subdomains: {String: SubdomainDetail} = {}
      for subdomainKey in subdomainKeys {
        let subRef = (&self.subdomains[subdomainKey] as &Subdomain?)!
        let detail = subRef.getDetail()
        subdomains[subdomainKey] = detail
      }

      var vaultBalances: {String: UFix64} = {}
      let vaultKeys = self.vaults.keys
      for vaultKey in vaultKeys {
        let balRef = (&self.vaults[vaultKey] as &{FungibleToken.Vault}?)!
        let balance = balRef.balance
        vaultBalances[vaultKey] = balance
      }

      var collections:{String: [UInt64]} = {}

      let collectionKeys = self.collections.keys
      for collectionKey in collectionKeys {
        let collectionRef = (&self.collections[collectionKey] as &{NonFungibleToken.Collection}?)!
        let ids = collectionRef!.getIDs()
        collections[collectionKey] = ids
      }

      let detail = DomainDetail(
        id: self.id,
        owner: owner,
        name: self.getDomainName(), 
        nameHash: self.nameHash,
        expiredAt: expired,
        addresses: self.getAllAddresses(),
        texts: self.getAllTexts(),
        parentName: self.parent,
        subdomainCount: self.subdomainCount,
        subdomains: subdomains,
        createdAt: self.createdAt,
        vaultBalances: vaultBalances,
        collections: collections,
        receivable: self.receivable,
        deprecated: Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id)
      )
      return detail
    }

    access(all) fun getSubdomainDetail(nameHash: String): SubdomainDetail {
      let subdomainRef = (&self.subdomains[nameHash] as &Subdomain?)!
      return subdomainRef.getDetail()
    }


    access(all) fun getSubdomainsDetail(): [SubdomainDetail] {
      let ids = self.subdomains.keys
      var subdomains:[SubdomainDetail] = []
      for id in ids {
        // todo
        let subRef = (&self.subdomains[id] as &Subdomain?)!
        let detail = subRef.getDetail()
        subdomains.append(detail)
      }
      return subdomains
    }

    // create subdomain with domain
    access(all) fun createSubDomain(name: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }

      let subForbidChars = self.getText(key: "_forbidChars") ?? "!@#$%^&*()<>? ./"

      for char in subForbidChars.utf8 {
      if name.utf8.contains(char) {
        panic("Domain name illegal ...")
      }
    }
    
      let domainHash = self.nameHash.slice(from: 2, upTo: 66)
      let nameSha = String.encodeHex(HashAlgorithm.SHA3_256.hash(name.utf8))
      let nameHash = "0x".concat(String.encodeHex(HashAlgorithm.SHA3_256.hash(domainHash.concat(nameSha).utf8)))
      
      if self.subdomains[nameHash] != nil {
        panic("Subdomain already existed.")
      }
      let subdomain <- create Subdomain(
        id: self.subdomainCount,
        name: name,
        nameHash: nameHash,
        parent: self.getDomainName(),
        parentNameHash: self.nameHash
      )

      let oldSubdomain <- self.subdomains[nameHash] <- subdomain
      self.subdomainCount = self.subdomainCount + (1 as UInt64)
      
      emit SubDomainCreated(id: self.subdomainCount, hash: nameHash)
      destroy oldSubdomain
    }

    access(all) fun removeSubDomain(nameHash: String){
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }
      self.subdomainCount = self.subdomainCount - (1 as UInt64)
      let oldToken <- self.subdomains.remove(key: nameHash) ?? panic("missing subdomain")

      emit SubDomainRemoved(id: oldToken.id, hash: nameHash)

      destroy oldToken

    }

    access(all) fun depositVault(from: @{FungibleToken.Vault}, senderRef: &{FungibleToken.Receiver}?) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.receivable : "Domain is not receivable"
      }
      let typeKey = from.getType().identifier
      // add type whitelist check 
      assert(FNSConfig.checkFTWhitelist(typeKey) == true, message: "FT type is not in inbox whitelist")
      let amount = from.balance
      let address = from.owner?.address
      if self.vaults[typeKey] == nil {
        self.vaults[typeKey] <-! from
      } else {
        let vault = (&self.vaults[typeKey] as &{FungibleToken.Vault}?)!
        vault.deposit(from: <- from)
      }
      emit DomainVaultDeposited(nameHash: self.nameHash, vaultType: typeKey, amount: amount, from: senderRef?.owner?.address )

    }

    access(all) fun withdrawVault(key: String, amount: UFix64): @{FungibleToken.Vault} {
      pre {
        self.vaults[key] != nil : "Vault not exsit..."
      }
      let vaultRef = (&self.vaults[key] as auth(FungibleToken.Withdraw) &{FungibleToken.Vault}?)!
      let balance = vaultRef.balance
      var withdrawAmount = amount
      if amount == 0.0 {
        withdrawAmount = balance
      }
      emit DomainVaultWithdrawn(nameHash: self.nameHash, vaultType: key, amount: balance, from: Domains.getRecords(self.nameHash))
      return <- vaultRef.withdraw(amount: withdrawAmount)
    }

    access(all) fun addCollection(collection: @{NonFungibleToken.Collection}) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
        self.receivable : "Domain is not receivable"
      }

      let typeKey = collection.getType().identifier
      assert(FNSConfig.checkNFTWhitelist(typeKey) == true, message: "NFT type is not in inbox whitelist")

      if collection.isInstance(Type<@Domains.Collection>()) {
        panic("Do not nest domain resource")
      }
      let address = collection.owner?.address
      if self.collections[typeKey] == nil {
        self.collections[typeKey] <-! collection
        emit DomainCollectionAdded(nameHash: self.nameHash, collectionType: typeKey)
      } else {
        if collection.getIDs().length > 0 {
          panic("collection not empty ")
        }
        destroy collection
      }
    }

    access(all) fun checkCollection(key: String): Bool {
      return self.collections[key] != nil
    }

    access(all) fun depositNFT(key: String, token: @{NonFungibleToken.NFT}, senderRef: &{NonFungibleToken.CollectionPublic}?) {
      pre {
        self.collections[key] != nil : "Cannot find NFT collection..."
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }
      assert(FNSConfig.checkNFTWhitelist(key) == true, message: "NFT type is not in inbox whitelist")

      let collectionRef = (&self.collections[key] as &{NonFungibleToken.Collection}?)!

      emit DomainCollectionDeposited(nameHash: self.nameHash, collectionType: key, itemId: token.id, from: senderRef?.owner?.address)

      collectionRef.deposit(token: <- token)
    }

    access(all) fun withdrawNFT(key: String, itemId: UInt64): @{NonFungibleToken.NFT} {
      pre {
        self.collections[key] != nil : "Cannot find NFT collection..."
      }
      let collectionRef = (&self.collections[key] as auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}?)!

      emit DomainCollectionWithdrawn(nameHash: self.nameHash, collectionType: key, itemId: itemId, from: Domains.getRecords(self.nameHash))

      return <- collectionRef.withdraw(withdrawID: itemId)
    }

    access(all) fun setReceivable(_ flag: Bool) {
      pre {
        !Domains.isExpired(self.nameHash) : Domains.domainExpiredTip
        !Domains.isDeprecated(nameHash: self.nameHash, domainId: self.id) : Domains.domainDeprecatedTip
      }
      self.receivable = flag
      if flag == false {
        emit DomainReceiveClosed(name: self.getDomainName())
      } else {
        emit DomainReceiveOpened(name: self.getDomainName())
      }
    }

    access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
      return <- Domains.createEmptyCollection(nftType: Type<@Domains.NFT>())
    }
    
  }

  access(all) resource interface CollectionPublic {

    access(all) fun deposit(token: @{NonFungibleToken.NFT})

    access(all) fun getIDs(): [UInt64]

    access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}?

    access(all) fun borrowDomain(id: UInt64): &Domains.NFT

    access(all) fun borrowViewResolver(id: UInt64): &{ViewResolver.Resolver}
  }

  // TODO return the content for this NFT
  access(all) resource interface CollectionPrivate {

    access(account) fun mintDomain(name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)

    access(all) fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT

  }


  // NFT collection 
  access(all) resource Collection: NonFungibleToken.Collection, CollectionPublic, CollectionPrivate {

    access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}

    init () {
      self.ownedNFTs <- {}
    }

    // withdraw removes an NFT from the collection and moves it to the caller
    access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
      let domain <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing domain")
      
      emit Withdraw(id: domain.id, from: self.owner?.address)

      return <-domain
    }

    access(all) fun deposit(token: @{NonFungibleToken.NFT}) {

      let token <- token as! @{NonFungibleToken.NFT, Domains.DomainPublic}
      let id: UInt64 = token.id
      let nameHash = token.nameHash

      if Domains.isExpired(nameHash) {
        panic(Domains.domainExpiredTip)
      }

      if Domains.isDeprecated(nameHash: token.nameHash, domainId: token.id) {
        panic(Domains.domainDeprecatedTip)
      }
      // update the owner record for new domain owner
      
      Domains.updateRecords(nameHash: nameHash, address: self.owner?.address)
      
      // add the new token to the dictionary which removes the old one  
      // todo
      let oldToken <- self.ownedNFTs[id] <- token as! @{NonFungibleToken.NFT}

      emit Deposit(id: id,to: self.owner?.address)

      destroy oldToken
    }

    // getIDs returns an array of the IDs that are in the collection
    access(all) view fun getIDs(): [UInt64] {

      return self.ownedNFTs.keys
    }

     access(all) view fun getLength(): Int {
        return self.ownedNFTs.keys.length
    }

    access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
      return &self.ownedNFTs[id] as &{NonFungibleToken.NFT}?
    }


    access(all) view fun borrowViewResolver(id: UInt64): &{ViewResolver.Resolver} {
      let nft = (&self.ownedNFTs[id] as &{NonFungibleToken.NFT}?)!
      let domainNFT = nft as! &Domains.NFT
      return domainNFT as &{ViewResolver.Resolver}
    }

     access(all) view fun getContractViews(resourceType: Type?): [Type] {
      return [
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>()
      ]
    }
    
    // Borrow domain for public use
    access(all) fun borrowDomain(id: UInt64): &Domains.NFT {
      pre {
        self.ownedNFTs[id] != nil: "domain doesn't exist"
      }
      let ref = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}?
      return ref! as! &Domains.NFT
    }

    // Borrow domain for domain owner 
    access(all) fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT {
      pre {
        self.ownedNFTs[id] != nil: "domain doesn't exist"
      }
      let ref = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}?
      return ref! as! &Domains.NFT
    }

    access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
      return <-Domains.createEmptyCollection(nftType: Type<@Domains.NFT>())
    }

    /// getSupportedNFTTypes returns a list of NFT types that this receiver accepts
    access(all) view fun getSupportedNFTTypes(): {Type: Bool} {
      let supportedTypes: {Type: Bool} = {}
      supportedTypes[Type<@Domains.NFT>()] = true
      return supportedTypes
    }

    /// Returns whether or not the gisSupportedNFTTypeiven type is accepted by the collection
    /// A collection that can accept any type should just return true by default
    access(all) view fun isSupportedNFTType(type: Type): Bool {
      if type == Type<@Domains.NFT>() {
        return true
      } else {
        return false
      }
    }

    access(account) fun mintDomain(name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
      
      if Domains.getRecords(nameHash) != nil {
        let isExpired = Domains.isExpired(nameHash)

        if isExpired == false {
          panic("The domain is not available")
        }
        let currentOwnerAddr = Domains.getRecords(nameHash)!
        let account = getAccount(currentOwnerAddr)

        var deprecatedDomain: &{Domains.DomainPublic}? = nil

        let currentId = Domains.getDomainId(nameHash)
        
        let deprecatedInfo = DomainDeprecatedInfo(
          id: currentId!,
          owner: currentOwnerAddr,
          name: name,
          nameHash:nameHash,
          parentName: parentName,
          deprecatedAt: getCurrentBlock().timestamp,
          trigger: receiver.address
        )
        
        var deprecatedRecords: {UInt64: DomainDeprecatedInfo} = Domains.getDeprecatedRecords(nameHash) ?? {}

        deprecatedRecords[currentId!] = deprecatedInfo

        Domains.updateDeprecatedRecords(nameHash: nameHash, records: deprecatedRecords)
       
      }

      let domain <- create Domains.NFT(
        id: Domains.totalSupply,
        name: name,
        nameHash: nameHash,
        parent: parentName,
      )
      // todo
      let nft <- domain as! @{NonFungibleToken.NFT}
      
      Domains.updateRecords(nameHash: nameHash, address: receiver.address)
      Domains.updateExpired(nameHash: nameHash, time: expiredAt)
      Domains.updateIdMap(nameHash: nameHash, id: nft.id)
      Domains.totalSupply = Domains.totalSupply + 1 as UInt64

      emit DomainMinted(id: nft.id, name: name, nameHash: nameHash, parentName: parentName, expiredAt: expiredAt, receiver: receiver.address)
      receiver.borrow()!.deposit(token: <- nft)
    }

  }


  access(all) fun createEmptyCollection(nftType: Type): @{NonFungibleToken.Collection} {

    let collection <- create Collection()
    return <- collection
  }

  access(all) view fun getContractViews(resourceType: Type?): [Type] {
    return [
      Type<MetadataViews.NFTCollectionData>(),
      Type<MetadataViews.NFTCollectionDisplay>()
    ]
  }

  access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? {
    switch viewType {
      case Type<MetadataViews.NFTCollectionData>():
        let collectionData = MetadataViews.NFTCollectionData(
          storagePath: Domains.CollectionStoragePath,
          publicPath: Domains.CollectionPublicPath,
          publicCollection: Type<&Domains.Collection>(),
          publicLinkedType: Type<&Domains.Collection>(),
          createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
            return <-Domains.createEmptyCollection(nftType: Type<@Domains.NFT>())
          })
        )
        return collectionData
      case Type<MetadataViews.NFTCollectionDisplay>():
        let squareMedia = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
                url: "https://www.flowns.org/assets/flowns_logo_light.svg"
            ),
            mediaType: "image/svg+xml"
        )
        let banerMedia = MetadataViews.Media(
            file: MetadataViews.HTTPFile(
                url: "https://www.flowns.org/assets/flowns_logo_light.svg"
            ),
            mediaType: "image/svg+xml"
        )
        return MetadataViews.NFTCollectionDisplay(
          name: "The Flowns domain Collection",
          description: "This collection is managed by Flowns and present the ownership of domain.",
          externalURL: MetadataViews.ExternalURL("https://flowns.org"),
          squareImage: squareMedia,
          bannerImage: banerMedia,
          socials: {
              "twitter": MetadataViews.ExternalURL("https://twitter.com/flownsorg"),
              "discord": MetadataViews.ExternalURL("https://discord.gg/fXz4gBaYXd"),
              "website": MetadataViews.ExternalURL("https://flowns.org"),
              "medium": MetadataViews.ExternalURL("https://medium.com/@Flowns")
          }
        )
      }
      return nil
    }

  // Get domain's expired time in timestamp 
  access(all) fun getExpiredTime(_ nameHash: String) : UFix64? {
    return self.expired[nameHash]
  }

  // Get domain's expired status
  access(all) view fun isExpired(_ nameHash: String): Bool {    
    let currentTimestamp = getCurrentBlock().timestamp
    let expiredTime =  self.expired[nameHash]
    if expiredTime != nil {
      return currentTimestamp >= expiredTime!
    }
    return false
  }

access(all) view fun isDeprecated(nameHash: String, domainId: UInt64): Bool {
    let deprecatedRecords = self.deprecated[nameHash] ?? {}
    return deprecatedRecords[domainId] != nil
  }

  // Get domain's owner address
  access(all) fun getRecords(_ nameHash: String) : Address? {
    let address = self.records[nameHash]
    return address
  }

  // Get domain's id by namehash
  access(all) fun getDomainId(_ nameHash: String) : UInt64? {
    let id = self.idMap[nameHash]
    return id
  }

  access(all) fun getDeprecatedRecords(_ nameHash: String): {UInt64: DomainDeprecatedInfo}? {
    return self.deprecated[nameHash]
  }

  access(all) fun getAllRecords(): {String: Address} {
    return self.records
  }

  access(all) fun getAllExpiredRecords(): {String: UFix64} {
    return self.expired
  }

  access(all) fun getAllDeprecatedRecords(): {String: {UInt64: DomainDeprecatedInfo }} {
    return self.deprecated
  }

  access(all) fun getIdMap(): {String: UInt64 } {
    return self.idMap
  }

  access(all) fun verifySignature(message: String, messagePrefix: String?, hashTag: String?, hashAlgorithm: HashAlgorithm, publicKey: [UInt8], signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]) :Bool {
      
    let messageToVerify = (messagePrefix ?? "").concat(message)
    let keyToVerify = PublicKey(publicKey: publicKey, signatureAlgorithm: signatureAlgorithm)
    let isValid = keyToVerify.verify(
        signature: signature,
        signedData: messageToVerify.utf8,
        domainSeparationTag: hashTag ?? "",
        hashAlgorithm: hashAlgorithm
    )
    if !isValid {
        return false
    }
    return true
  }

   access(all) fun ethPublicKeyToAddress(publicKey:[UInt8]) :String {
    pre{
      publicKey.length > 0 : "Invalid public key"
    }
    let publicKeyStr = String.encodeHex(publicKey)
    // let pk = publicKeyStr.slice(from: 2, upTo: publicKey.length)
    let pkArr = publicKeyStr.decodeHex()
    let hashed = HashAlgorithm.KECCAK_256.hash(pkArr)
    let hashedStr = String.encodeHex(hashed)
    let len = hashedStr.length
    let addr = hashedStr.slice(from: len-40, upTo: len)

    return "0x".concat(addr)

   }

  access(account) fun updateDeprecatedRecords(nameHash: String, records: {UInt64: DomainDeprecatedInfo}) {
    self.deprecated[nameHash] = records
  }

  // update records in case domain name not match hash
  access(account) fun updateRecords(nameHash: String, address: Address?) {
    self.records[nameHash] = address
  }

  access(account) fun updateExpired(nameHash: String, time: UFix64) {
    self.expired[nameHash] = time
  }

  access(account) fun updateIdMap(nameHash: String, id: UInt64) {
    self.idMap[nameHash] = id
  }

	init() {

    self.totalSupply = 0
    self.CollectionPublicPath =/public/fnsDomainCollection
    self.CollectionStoragePath =/storage/fnsDomainCollection
    self.domainExpiredTip =  "Domain expired, please renew it."
    self.domainDeprecatedTip =  "Domain deprecated."
    self.records = {}
    self.expired = {}
    self.deprecated = {}
    self.idMap = {}
    let account = self.account
    let collection <- create Collection()

    account.storage.save(<- collection, to: self.CollectionStoragePath)

    let collectionCap = account.capabilities.storage.issue<&{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic}>(self.CollectionStoragePath)
    account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)

    emit ContractInitialized()
	}
}

 