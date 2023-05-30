// #Sireum

import org.sireum._


def parseTime(_time: String): Z = {
  val time = ops.StringOps(_time)
  val millis = Z(time.substring(time.indexOf('.') + 1, time.size)).get
  if (time.indexOf(':') >= 0) {
    val minAsMs = Z(time.substring(0, time.indexOf(':'))).get * 60000
    val secAsMs = Z(time.substring(time.indexOf(':') + 1, time.indexOf('.'))).get * 1000
    return  minAsMs + secAsMs + millis
  } else {
    val minAsMs = Z(time.substring(0, time.indexOf('.'))).get * 1000
    return minAsMs + millis
  }
}

def split(s: String): (Z, Z) = {
  val ss = ops.StringOps(s)
  val num = Z(ss.substring(ss.indexOf(':') + 2, ss.indexOf('(') - 1)).get
  val time = ops.StringOps(ss.substring(ss.stringIndexOf("(time: ") + 7, s.size - 1))
  val ms = if (time.endsWith("s"))
    parseTime(time.substring(0, time.size - 1))
  else
    parseTime(time.s)

  return (num, ms)
}


val samples: ISZ[String]= ISZ(
  "Number of SMT2 verification condition checking: 1 (time: 0.094s)",
  "Number of SMT2 satisfiability checking: 0 (time: 0.000s)",
  "Number of SMT2 verification condition checking: 12 (time: 14.342s)",
  "Number of SMT2 satisfiability checking: 33 (time: 1:12.419)",
  "Number of SMT2 satisfiability checking: 33 (time: 2:12.419)",
"Number of SMT2 satisfiability checking: 33 (time: 2:30.500)"
)

for(s <- samples) {
  println(split(s))
}

