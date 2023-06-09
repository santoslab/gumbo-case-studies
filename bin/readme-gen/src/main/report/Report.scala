// #Sireum
package report

import org.sireum._
import org.sireum.message.Reporter
import report.ReadmeGen.Project

@datatype class Block (val tag: String,
                       content: Option[String])

@datatype class Level (val tag: String,
                       val title: Option[String],
                       val description: Option[String],
                       val content: ISZ[Block],
                       val subLevels: ISZ[Level])
object Report {

  def genReport(project: Project, rootDir: Os.Path, reporter: Reporter): Report = {
    return Report().genReport()
  }
}

@datatype class Report {

  def genReport(): Report = {

    return this
  }

  def genArchitectureSection(project: Project): Level = {
    return Level("arch-section",
      Some("AADL Architecture"),
      None(),
      ISZ(),
      ISZ()
    )
  }
}