import dotenv from 'dotenv'
dotenv.config()

export const nodeUrl = process.env.FLOW_ACCESS_NODE

export const privateKey = process.env.FLOW_ACCOUNT_PRIVATE_KEY

export const accountKeyId = process.env.FLOW_ACCOUNT_KEY_ID

export const accountAddr = process.env.FLOW_ACCOUNT_ADDRESS

export const publicKey = process.env.FLOW_ACCOUNT_PUBLIC_KEY

export const paths = {
  setup: {
    initDomainCollection: '../cadence/transactions/setup/init_domains_collection.cdc',
    initFlownsAdminStorage: '../cadence/transactions/setup/init_flowns_admin_storage.cdc',
    setupAdminServer: '../cadence/transactions/setup/setup_admin_server.cdc',
    mintFlowRootDomain: '../cadence/transactions/setup/mint_flow_root_domains.cdc',
    setupRootDomainServer: '../cadence/transactions/setup/setup_root_domain_server.cdc',
    setupDomainRentPrice: '../cadence/transactions/setup/setup_domain_rent_price.cdc',
  },
  scripts: {
    checkDomainCollection: '../cadence/scripts/check_domain_collection.cdc',
    checkFlownsAdmin: '../cadence/scripts/check_flowns_admin.cdc',
    queryRootDomainsById: '../cadence/scripts/query_root_domains_by_id.cdc',
    queryRootDomains: '../cadence/scripts/query_root_domains.cdc',
  },
}
