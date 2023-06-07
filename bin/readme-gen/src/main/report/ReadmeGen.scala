// #Sireum

package report

import org.sireum._
import org.sireum.hamr.codegen.common.symbols.SymbolTable
import org.sireum.hamr.codegen.common.util.CodeGenConfig
import org.sireum.message.Reporter

object ReadmeGen extends App {

  val gumboRootDir: Os.Path = {
    val c = Os.path(".").up.up.up
    if (!(c/ "isolette").exists || !(c / "rts").exists || !(c / "temp_control" / "sporadic").exists) {
      halt(s"Root dir should contain all the subprojects: $c")
    }
    c
  }

  @datatype class Project(val title: String,
                          val description: Option[String],
                          val projectRootDir: Os.Path,
                          val air: Os.Path,
                          val configs: ISZ[Cli.SireumHamrCodegenOption]
                         )

  val tempControlSporadic: Project = {
    val projRootDir = gumboRootDir / "temp_control" / "sporadic"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title ="Temperature Control Sporadic",
      description = None(),
      projectRootDir = projRootDir,
      air = defaultDirs.json,
      configs = ISZ(Util.baseOptions(
        packageName = Some("tc"),
        args = ISZ(defaultDirs.json.value),
        outputDir = Some(defaultDirs.slangDir.value),
        aadlRootDir = Some(defaultDirs.aadlDir.value)
      ))
    )
  }

  val isolette: Project = {
    val projRootDir = gumboRootDir / "isolette"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title = "Isolette",
      description = None(),
      projectRootDir = projRootDir,
      air = defaultDirs.json,
      configs = ISZ(Util.baseOptions(
        packageName = Some("isolette"),
        args = ISZ(defaultDirs.json.value),
        outputDir = Some(defaultDirs.slangDir.value),
        aadlRootDir = Some(defaultDirs.aadlDir.value)
      ))
    )
  }

  val rts: Project = {
    val projRootDir = gumboRootDir / "rts"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title = "RTS",
      description = None(),
      projectRootDir = projRootDir,
      air = defaultDirs.json,
      configs = ISZ(Util.baseOptions(
        packageName = Some("RTS"),
        args = ISZ(defaultDirs.json.value),
        outputDir = Some(defaultDirs.slangDir.value),
        aadlRootDir = Some(defaultDirs.aadlDir.value)
      ))
    )
  }

  val projects: ISZ[Project] = ISZ(isolette, rts, tempControlSporadic)

  def main(args: ISZ[String]): Z = {
    run()
    return 0
  }

  def run(): Unit = {
    val reporter = Reporter.create

    for(project <- projects) {

      for(config <- project.configs) {

        println("***************************************")
        println(s"${project.projectRootDir} -- ${config.platform})")
        println("***************************************")

        org.sireum.cli.HAMR.codeGen(config, reporter)

        println(reporter.hasError)

        reporter.printMessages()
      }
    }
  }
}
