// #Sireum

package report

import org.sireum._
import org.sireum.hamr.codegen.common.symbols.SymbolTable
import org.sireum.hamr.codegen.common.util.CodeGenConfig
import org.sireum.message.Reporter

object ReadmeGen extends App {

  val runCodegen: B = F
  val replaceReadmes: B = T

  val repoRootDir: Os.Path = {
    val c = Os.path(".").up.up.up
    if (!(c/ "isolette").exists || !(c / "rts").exists || !(c / "temp_control" / "sporadic").exists) {
      halt(s"Root dir should contain all the subprojects: $c")
    }
    c
  }

  @datatype class Project(val title: String,
                          val description: Option[String],
                          val projectRootDir: Os.Path,
                          //val aadlRootDir: Os.Path,
                          val air: Os.Path,
                          //val packageName: String,
                          val configs: ISZ[Cli.SireumHamrCodegenOption]
                         )

  val tempControlSporadic: Project = {
    val projRootDir = repoRootDir / "temp_control" / "sporadic"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title ="Temperature Control Sporadic",
      description = None(),
      projectRootDir = projRootDir,
      //aadlRootDir = defaultDirs.aadlDir,
      //packageName = Some("tc"),
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
    val projRootDir = repoRootDir / "isolette"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title = "Isolette",
      description = None(),
      projectRootDir = projRootDir,
      //aadlRootDir = defaultDirs.aadlDir,
      air = defaultDirs.json,
      //packageName = Some("isolette"),
      configs = ISZ(Util.baseOptions(
        packageName = Some("isolette"),
        args = ISZ(defaultDirs.json.value),
        outputDir = Some(defaultDirs.slangDir.value),
        aadlRootDir = Some(defaultDirs.aadlDir.value)
      ))
    )
  }

  val rts: Project = {
    val projRootDir = repoRootDir / "rts"
    val defaultDirs = Util.getDefaultDirectories(projRootDir)

    Project(
      title = "RTS",
      description = None(),
      projectRootDir = projRootDir,
      //aadlRootDir = defaultDirs.aadlDir,
      air = defaultDirs.json,
      //packageName = Some("RTS"),
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

    var reports: ISZ[Report] = ISZ()

    for(project <- projects) {

      val aadlRootDir = Os.path(project.configs(0).aadlRootDir.get)
      val packageName = project.configs(0).packageName.get

      assert(aadlRootDir.exists)

      for(config <- project.configs) {
        assert (config.aadlRootDir.get == aadlRootDir.value)
        assert (config.packageName.get == packageName)

        println("***************************************")
        println(s"${project.projectRootDir} -- ${config.platform})")
        println("***************************************")

        if (runCodegen) {
          org.sireum.cli.HAMR.codeGen(config, reporter)
        }

        reporter.printMessages()
      }

      if (!reporter.hasError) {
        val readmeLoc = project.projectRootDir / "readme.md"
        val readmeContent = Report.genReport(project, packageName, aadlRootDir, repoRootDir, reporter)
        if (!reporter.hasError) {
          if (!readmeLoc.exists || replaceReadmes) {
            Report.overwrite(readmeLoc, readmeContent)
          } else {
            Report.weave(readmeLoc, readmeContent)
          }
        }
      }
    }
  }
}
