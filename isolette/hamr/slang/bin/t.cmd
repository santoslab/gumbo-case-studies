// #Sireum

import org.sireum._


def split(s: String): (Z, Z) = {
  val ss = ops.StringOps(s)
  val num = Z(ss.substring(ss.indexOf(':') + 2, ss.indexOf('(') - 1)).get

  val time = ops.StringOps(ss.substring(ss.stringIndexOf("(time: ") + 7, s.size - 1))
  if (time.endsWith("s")) {
    // 14.342s
    val _time = ops.StringOps(time.substring(0, time.size - 1))
    val ms = st"${(_time.split(c => c == '.'))}".render
    return (num, Z(ms).get)
  } else {
    // 1:12.419
    val min = Z(time.substring(0, time.indexOf(':'))).get
    val rest = st"${(ops.StringOps(time.substring(time.indexOf(':') + 1, time.size)).split(c => c == '.'))}".render
    val mills = Z(rest).get
    val ms = min * 60000 + mills
    return (num, ms)
  }
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