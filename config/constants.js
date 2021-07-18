import dotenv from 'dotenv';
dotenv.config();


export const nodeUrl = process.env.FLOW_ACCESS_NODE

export const privateKey = process.env.FLOW_ACCOUNT_PRIVATE_KEY

export const accountKeyId = process.env.FLOW_ACCOUNT_KEY_ID

export const accountAddr = process.env.FLOW_ACCOUNT_ADDRESS

export const publicKey = process.env.FLOW_ACCOUNT_PUBLIC_KEY

export const paths = {
  'setup':{
    initDomainCollection:'../cadence/transactions/setup/init_domains_collection.cdc'
  }
}
