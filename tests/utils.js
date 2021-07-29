export const checkTrxSealed = (res) => {
  const { status } = res
  return status == 4
}
