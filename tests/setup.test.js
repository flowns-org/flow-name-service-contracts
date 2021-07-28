import { test1Authz } from '../utils/authz'
import { buildAndExecScript, buildSetupTrx, fclInit } from '../utils/index'

describe('Contract setup test cases', () => {
  beforeAll(() => {
    return fclInit()
  })
  test('init admin resource with admin', async () => {
    const res = await buildSetupTrx('initFlownsAdminStorage')
    console.log(res, '=========')

    expect(res).not.toBeNull()
    const { status, events } = res

    expect(status).toBe(4)
    expect(events.length).toBe(1)

    const res1 = await buildSetupTrx('initFlownsAdminStorage')
    expect(res1).toBeNull()
  })

  // test('init admin resource with no permission', async () => {
  //   const res = await buildSetupTrx('initFlownsAdminStorage', [], test1Authz())
	// 	console.log(res, '==========')
  //   expect(res).not.toBeNull()
  //   const { status, events } = res

  //   expect(status).toBe(4)
  //   expect(events.length).toBe(1)
  // })
})
