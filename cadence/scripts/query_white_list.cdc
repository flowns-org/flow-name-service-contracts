
import FNSConfig from 0xFNSConfig

pub fun main(type: String): {String: Bool} {
  
  return FNSConfig.getWhitelist(type)
}
