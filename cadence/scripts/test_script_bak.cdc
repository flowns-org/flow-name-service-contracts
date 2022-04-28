import FIND from 0x097bafa4e0b48eef

pub fun main(name: String): Address? {

  let status = FIND.status(name)
  if status == nil {
    return nil
  }
  if status.owner != nil {
    return status.owner
  }
  return nil
}