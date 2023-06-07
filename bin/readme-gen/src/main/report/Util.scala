// #Sireum

package report

import org.sireum._
import org.sireum.hamr.codegen.common.util.{CodeGenConfig, CodeGenIpcMechanism, CodeGenPlatform, ExperimentalOptions}

object Util {
  @datatype class Dirs(val rootDir: Os.Path,
                       val aadlDir: Os.Path,
                       val slangDir: Os.Path,
                       val json: Os.Path)
  def getDefaultDirectories(projRootDir: Os.Path): Dirs = {
    def exists(path: Os.Path): Os.Path = {
      if (!path.exists) {
        halt(s"${path} does not exist")
      }
      return path
    }
    def getJson(path: Os.Path): Os.Path = {
      val cands = Os.Path.walk(path, T, F, p => p.ext == "json")
      if (cands.size != 1) {
        halt(s"Found ${cands.size} json files in ${path}")
      }
      return cands(0)
    }
    return Dirs(
      rootDir = projRootDir,
      aadlDir = exists(projRootDir / "aadl"),
      slangDir = exists((projRootDir / "hamr" / "slang")),
      json = getJson(projRootDir / "aadl")
    )
  }


  val baseOptions: Cli.SireumHamrCodegenOption = Cli.SireumHamrCodegenOption(
    help = "",
    args = ISZ(),
    msgpack = F,
    verbose = T,
    platform = Cli.SireumHamrCodegenHamrPlatform.JVM,
    packageName = None(),

    noProyekIve = T,
    noEmbedArt = F,
    devicesAsThreads = F,
    excludeComponentImpl = F,
    genSbtMill = F,

    outputDir = None(),
    slangAuxCodeDirs = ISZ(),
    slangOutputCDir = None(),
    camkesOutputDir = None(),
    camkesAuxCodeDirs = ISZ(),
    aadlRootDir = None(),

    bitWidth = 32,
    maxStringSize = 256,
    maxArraySize = 1,
    runTranspiler = F,

    experimentalOptions = ISZ()
  )
}
