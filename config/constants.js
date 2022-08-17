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

export const flowNonFungibleAddr = process.env.FLOW_NONFUNGIBLE_ADDRESS

export const publicKey = process.env.FLOW_ACCOUNT_PUBLIC_KEY

export const alchemyKey = process.env.ALCHEMY_KEY

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
    setupAdminServer: buildPath('setup_admin_server.cdc', 'setup'),
    mintRootDomain: buildPath('mint_root_domains.cdc', 'setup'),
    setupRootDomainServer: buildPath('setup_root_domain_server.cdc', 'setup'),
    setupDomainRentPrice: buildPath('setup_domain_rent_price.cdc', 'setup'),
    mintFlowToken: buildPath('mint_flow_token.cdc', 'setup'),
    mintKibbleToken: buildPath('mint_kibble_token.cdc', 'setup'),
    initTokens: buildPath('init_tokens.cdc', 'setup'),
    mintFUSD: buildPath('mint_fusd.cdc', 'setup'),
    createFUSDMinter: buildPath('create_fusd_minter.cdc', 'setup'),
  },
  scripts: {
    checkDomainCollection: buildPath('check_domain_collection.cdc', 'script'),
    checkFlownsAdmin: buildPath('check_flowns_admin.cdc', 'script'),
    queryRootDomainsById: buildPath('query_root_domains_by_id.cdc', 'script'),
    queryRootDomains: buildPath('query_root_domains.cdc', 'script'),
    queryDomainRentPrice: buildPath('query_domain_rent_prices.cdc', 'script'),
    queryDomainAvailable: buildPath('query_domain_available.cdc', 'script'),
    queryFlowTokenBalance: buildPath('query_flow_balance.cdc', 'script'),
    queryDomainExpiredTime: buildPath('query_domain_expired_time.cdc', 'script'),
    queryDomainExpired: buildPath('query_domain_is_expired.cdc', 'script'),
    queryDomainRecord: buildPath('query_domain_record.cdc', 'script'),
    queryDomainRecordWithRaw: buildPath('query_domain_record_with_raw.cdc', 'script'),
    queryDomainInfo: buildPath('query_domain_info.cdc', 'script'),
    queryUsersAllDomain: buildPath('query_users_domains_info.cdc', 'script'),
    queryUsersDomainIds: buildPath('query_users_domain_ids.cdc', 'script'),
    queryUsersAllSubDomain: buildPath('query_subdomains_info.cdc', 'script'),
    queryRootDomainVaultBalance: buildPath('query_root_vault_balance.cdc', 'script'),
    queryFUSDBalance: buildPath('query_fusd_balance.cdc', 'script'),
    calcDomainHash: buildPath('calc_domain_hash.cdc', 'script'),
    calcDomainNameHashLocal: buildPath('calc_domain_name_hash_local.cdc', 'script'),
    queryDomainDeprecated: buildPath('query_domain_deprecated.cdc', 'script'),
    queryIsDeprecated: buildPath('query_domain_is_deprecated.cdc', 'script'),
    getCurrentBlockTimestamp: buildPath('get_block_timestamp.cdc', 'script'),
    getDomainNameHash: buildPath('get_domain_name_hash.cdc', 'script'),
    getAllDomainRecords: buildPath('get_all_domain_records.cdc', 'script'),
    getAllDomainExpiredRecords: buildPath('get_all_domain_expired_records.cdc', 'script'),
    getAllDomainDeprecatedRecords: buildPath('get_all_domain_deprecated_records.cdc', 'script'),
    calcHash: buildPath('calc_hash.cdc', 'script'),
    calcHashByContract: buildPath('calc_hash_by_contract.cdc', 'script'),
    queryDomainStatusBatch: buildPath('query_domain_status_batch.cdc', 'script'),
    queryDomainAvailableBatch: buildPath('query_domain_available_batch.cdc', 'script'),
    queryDomaimPrice: buildPath('query_domain_price.cdc', 'script'),
    queryDomaimId: buildPath('query_domain_id.cdc', 'script'),
    queryWhitelist: buildPath('query_white_list.cdc', 'script'),
    getDomainMetadata: buildPath('get_domain_metadata.cdc', 'script'),
    test: buildPath('test_script.cdc', 'script')
  },
  transactions: {
    registerDomain: buildPath('register_domain.cdc'),
    registerDomainBatch: buildPath('register_domain_batch.cdc'),
    registerDomainWithFUSD: buildPath('register_domain_with_fusd.cdc'),
    renewDomain: buildPath('renew_domain.cdc'),
    renewDomainWithHash: buildPath('renew_domain_with_hash.cdc'),
    renewDomainWithAdmin: buildPath('renew_domain_with_admin.cdc'),
    mintSubdomain: buildPath('mint_subdomain.cdc'),
    removeSubdomain: buildPath('remove_subdomain.cdc'),
    setDomainAddress: buildPath('set_domain_address.cdc'),
    setDomainText: buildPath('set_domain_text.cdc'),
    removeDomainText: buildPath('remove_domain_text.cdc'),
    removeDomainAddress: buildPath('remove_domain_address.cdc'),
    setSubdomainText: buildPath('set_subdomain_text.cdc'),
    removeSubdomainText: buildPath('remove_subdomain_text.cdc'),
    setSubdomainAddress: buildPath('set_subdomain_address.cdc'),
    removeSubdomainAddress: buildPath('remove_subdomain_address.cdc'),
    withdrawRootVault: buildPath('withdraw_root_vault.cdc'),
    mintDomain: buildPath('mint_domain.cdc'),
    mintDomainTo: buildPath('mint_domain_to.cdc'),
    mintDomainBatch: buildPath('mint_domain_batch.cdc'),
    createFUSDVault: buildPath('create_fusd_vault.cdc'),
    changeRootDomainVaultWithFusd: buildPath('change_root_domain_vault_with_fusd.cdc'),
    changeRootDomainVaultWithFlow: buildPath('change_root_domain_vault_with_flow.cdc'),
    setFlownsPauseStatus: buildPath('set_flowns_pause_status.cdc'),
    setDomainForbidChars: buildPath('set_domain_forbid_chars.cdc'),
    setRootDomainMinRentDuration: buildPath('set_root_domain_min_rent_duration.cdc'),
    setRootDomainMaxLength: buildPath('set_root_domain_max_length.cdc'),
    setRootDomainCommissionRate: buildPath('set_root_domain_commission_rate.cdc'),
    depositDomainVaultWithFlow: buildPath('deposit_domain_vault_with_flow.cdc'),
    withdrawVaultWithVaultType: buildPath('withdraw_domain_vault_with_vault_type.cdc'),
    sendNFTToDomain: buildPath('send_nft_to_domain.cdc'),
    withdrawNFTFromDomain: buildPath('withdraw_nft_from_domain.cdc'),
    transferDomainWithId: buildPath('transfer_domain_with_id.cdc'),
    transferDomainWithIdBatch: buildPath('transfer_domain_with_id_batch.cdc'),
    transferDomainWithHashName: buildPath('transfer_domain_with_hash_name.cdc'),
    transferDomainWithHashNameP: buildPath('transfer_domain_with_hash_name_public.cdc'),
    mintLilico: buildPath('mint_lilico_domain.cdc'),
    sendFTInbox: buildPath('send_vault_to_user_with_inbox.cdc'),
    sendNFTInbox: buildPath('send_nft_to_user_with_inbox.cdc'),
    withdrawFTInbox: buildPath('withdraw_domain_vault_with_init.cdc'),
    withdrawNFTInbox: buildPath('withdraw_domain_nft_with_init.cdc'),
    batchRenewWithHash: buildPath('batch_renew_domain_with_hash.cdc'),
    transferFlowBatch: buildPath('transfer_flow_batch.cdc'),
    setFTWhitelist: buildPath('set_ft_white_list.cdc'),
    setNFTWhitelist: buildPath('set_nft_white_list.cdc'),
  },
}
