package tc

import org.sireum._

object Reporter_Ext {

  val saveLoc: Os.Path = Os.path(Os.env("DSC_SAVE_LOC").get)

  def report(container: String): Unit = {
    println(Os.env("DSC_SAVE_LOC"))

    assert(saveLoc.exists, s"$saveLoc is not a file")

    this.synchronized {
      saveLoc.writeAppend(container)
      saveLoc.writeAppend("\n")
    }
  }
}
