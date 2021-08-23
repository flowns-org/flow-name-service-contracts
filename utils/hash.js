import Sha3 from 'js-sha3'
import uts46 from 'idna-uts46-hx'

export function namehash(inputName) {
  const sha3 = Sha3.sha3_256
  // Reject empty names:
  var node = ''
  for (var i = 0; i < 32; i++) {
    node += '00'
  }

  let name = normalize(inputName)

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

