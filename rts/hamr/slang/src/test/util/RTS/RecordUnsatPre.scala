// #Sireum
package RTS

import org.sireum._

object RecordUnsatPre {

  def report(container: String): Unit = {
    Reporter.report(container)
  }
}

@ext object Reporter {
  def report(container: String): Unit = $
}
