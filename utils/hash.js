import Sha3 from 'js-sha3'
import uts46 from 'idna-uts46-hx'
import emojiRegex from 'emoji-regex'

const chineseReg = /[\u4E00-\u9FCC\u3400-\u4DB5\uFA0E\uFA0F\uFA11\uFA13\uFA14\uFA1F\uFA21\uFA23\uFA24\uFA27-\uFA29]|[\ud840-\ud868][\udc00-\udfff]|\ud869[\udc00-\uded6\udf00-\udfff]|[\ud86a-\ud86c][\udc00-\udfff]|\ud86d[\udc00-\udf34\udf40-\udfff]|\ud86e[\udc00-\udc1d]/
export function namehash(inputName) {
  const sha3 = Sha3.sha3_256
  // Reject empty names:
  var node = ''
  for (var i = 0; i < 32; i++) {
    node += '00'
  }
  // const regex = emojiRegex()

  let name = inputName
  if (name) {
    var labels = name.split('.')

    for (var i = labels.length - 1; i >= 0; i--) {
      var labelSha = sha3(labels[i])
      node = sha3(node + labelSha)
    }
  }

  return '0x' + node
}

export function normalize(name) {
  return name ? uts46.toAscii(name, { useStd3ASCII: true, transitional: false }) : name
}
