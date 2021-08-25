import { build } from '@onflow/sdk'
import dotenv from 'dotenv'
dotenv.config()

export const nodeUrl = process.env.FLOW_ACCESS_NODE

export const privateKey = process.env.FLOW_ACCOUNT_PRIVATE_KEY

export const accountKeyId = process.env.FLOW_ACCOUNT_KEY_ID

export const accountAddr = process.env.FLOW_ACCOUNT_ADDRESS

export const flowTokenAddr = process.env.FLOW_TOKEN_ADDRESS

export const FUSDTokenAddr = process.env.FUSD_TOKEN_ADDRESS

export const KibbleTokenAddr = process.env.KIBBLE_TOKEN_ADDRESS

export const flowFungibleAddr = process.env.FLOW_FUNGIBLE_ADDRESS

export const publicKey = process.env.FLOW_ACCOUNT_PUBLIC_KEY

const buildPath = (fileName, type) => {
  let filePath = ''
  switch (type) {
    case 'setup':
      filePath = `../cadence/transactions/setup/${fileName}`
      break
    case 'script':
      filePath = `../cadence/scripts/${fileName}`
      break
    default:
      filePath = `../cadence/transactions/${fileName}`
  }
  return filePath
}

export const paths = {
  setup: {
    initDomainCollection: buildPath('init_domains_collection.cdc', 'setup'),
    initFlownsAdminStorage: buildPath('init_flowns_admin_storage.cdc', 'setup'),
    setupAdminServer: '../cadence/transactions/setup/setup_admin_server.cdc',
    mintRootDomain: '../cadence/transactions/setup/mint_root_domains.cdc',
    setupRootDomainServer: '../cadence/transactions/setup/setup_root_domain_server.cdc',
    setupDomainRentPrice: '../cadence/transactions/setup/setup_domain_rent_price.cdc',
    mintFlowToken: '../cadence/transactions/setup/mint_flow_token.cdc',
    mintKibbleToken: '../cadence/transactions/setup/mint_kibble_token.cdc',
    initTokens: '../cadence/transactions/setup/init_tokens.cdc',
    mintFUSD: '../cadence/transactions/setup/mint_fusd.cdc',
    createFUSDMinter: '../cadence/transactions/setup/create_fusd_minter.cdc',
  },
  scripts: {
    checkDomainCollection: '../cadence/scripts/check_domain_collection.cdc',
    checkFlownsAdmin: '../cadence/scripts/check_flowns_admin.cdc',
    queryRootDomainsById: '../cadence/scripts/query_root_domains_by_id.cdc',
    queryRootDomains: '../cadence/scripts/query_root_domains.cdc',
    queryDomainRentPrice: '../cadence/scripts/query_domain_rent_prices.cdc',
    queryDomainAvailable: '../cadence/scripts/query_domain_available.cdc',
    queryFlowTokenBalance: buildPath('query_flow_balance.cdc', 'script'),
    queryDomainExpiredTime: buildPath('query_domain_expired_time.cdc', 'script'),
    queryDomainExpired: buildPath('query_domain_is_expired.cdc', 'script'),
    queryDomainRecord: buildPath('query_domain_record.cdc', 'script'),
    queryDomainInfo: buildPath('query_domain_info.cdc', 'script'),
    queryUsersAllDomain: buildPath('query_users_domains_info.cdc', 'script'),
    queryUsersAllSubDomain: buildPath('query_subdomains_info.cdc', 'script'),
    queryRootDomainVaultBalance: buildPath('query_root_vault_balance.cdc', 'script'),
    queryFUSDBalance: buildPath('query_fusd_balance.cdc', 'script'),
    calcDomainHash: buildPath('calc_domain_hash.cdc', 'script'),
    calcDomainNameHash: buildPath('calc_domain_name_hash.cdc', 'script'),
    queryDomainDeprecated: buildPath('query_domain_deprecated.cdc', 'script'),
    getCurrentBlockTimestamp: buildPath('get_block_timestamp.cdc', 'script'),
    getDomainNameHash: buildPath('get_domain_name_hash.cdc', 'script'),
    getAllDomainRecords: buildPath('get_all_domain_records.cdc', 'script'),
    getAllDomainExpiredRecords: buildPath('get_all_domain_expired_records.cdc', 'script'),
    getAllDomainDeprecatedRecords: buildPath('get_all_domain_deprecated_records.cdc', 'script'),
    calcHash: buildPath('calc_hash.cdc', 'script'),
  },
  transactions: {
    registerDomain: '../cadence/transactions/register_domain.cdc',
    registerDomainWithFUSD: '../cadence/transactions/register_domain_with_fusd.cdc',
    renewDomain: '../cadence/transactions/renew_domain.cdc',
    mintSubdomain: '../cadence/transactions/mint_subdomain.cdc',
    removeSubdomain: '../cadence/transactions/remove_subdomain.cdc',
    setDomainAddress: '../cadence/transactions/set_domain_address.cdc',
    setDomainText: '../cadence/transactions/set_domain_text.cdc',
    removeDomainText: '../cadence/transactions/remove_domain_text.cdc',
    removeDomainAddress: '../cadence/transactions/remove_domain_address.cdc',
    setSubdomainText: '../cadence/transactions/set_subdomain_text.cdc',
    removeSubdomainText: '../cadence/transactions/remove_subdomain_text.cdc',
    setSubdomainAddress: '../cadence/transactions/set_subdomain_address.cdc',
    removeSubdomainAddress: '../cadence/transactions/remove_subdomain_address.cdc',
    withdrawRootVault: '../cadence/transactions/withdraw_root_vault.cdc',
    mintDomain: '../cadence/transactions/mint_domain.cdc',
    createFUSDVault: '../cadence/transactions/create_fusd_vault.cdc',
    changeRootDomainVaultWithFusd: '../cadence/transactions/change_root_domain_vault_with_fusd.cdc',
    setFlownsPauseStatus: '../cadence/transactions/set_flowns_pause_status.cdc',
    setDomainForbidChars: '../cadence/transactions/set_domain_forbid_chars.cdc',
    setRootDomainMinRentDuration: '../cadence/transactions/set_root_domain_min_rent_duration.cdc',
    setRootDomainMaxLength: '../cadence/transactions/set_root_domain_max_length.cdc',
    depositDomainVaultWithFlow: '../cadence/transactions/deposit_domain_vault_with_flow.cdc',
    withdrawVaultWithVaultType: '../cadence/transactions/withdraw_domain_vault_with_vault_type.cdc',
    sendNFTToDomain: '../cadence/transactions/send_nft_to_domain.cdc',
    withdrawNFTFromDomain: '../cadence/transactions/withdraw_nft_from_domain.cdc',
    transferDomainWithId: '../cadence/transactions/transfer_domain_with_id.cdc',
    transferDomainWithHashName: '../cadence/transactions/transfer_domain_with_hash_name.cdc',
  },
}
