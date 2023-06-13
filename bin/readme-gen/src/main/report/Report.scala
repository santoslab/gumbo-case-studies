// #Sireum
package report

import org.sireum._
import org.sireum.hamr.codegen.common.StringUtil
import org.sireum.hamr.codegen.common.symbols.{AadlComponent, AadlThread, SymbolTable}
import org.sireum.hamr.ir.Classifier
import org.sireum.message.{Position, Reporter}
import report.ReadmeGen.{Project, repoRootDir, projects}
import org.sireum.U32._

@datatype class Block(val tag: String,
                      content: Option[ST])

@datatype class Level(val tag: String,
                      val title: Option[ST],
                      val description: Option[ST],
                      val content: ISZ[Block],
                      val subLevels: ISZ[Level])

object Report {
  def wrapWithTag(tag: String, isTitle: B, content: Option[ST]): ST = {
    val (start, end): (String, String) = (s"<!--${tag}_start-->", s"<!--${tag}_end-->")
    val ret: ST = {
      if (isTitle) st"${start}${content}${end}"
      else
        st"""${start}
            |${content}
            |${end}"""
    }
    return ret
  }

  def weave(readmeLoc: Os.Path, readmeContent: Level): Unit = {
  }

  def overwrite(readmeLoc: Os.Path, level: Level): Unit = {
    def renderLevel(l: Level, pos: Z): ST = {
      val hashes = st"${(for (i <- 0 to pos) yield "#", "")}"

      def renderBlock(block: Block): ST = {
        wrapWithTag(s"${l.tag}-${block.tag}", F, block.content)
      }

      return (
        st"""$hashes ${wrapWithTag(s"${l.tag}-title", T, l.title)}
            |${wrapWithTag(s"${l.tag}-description", F, l.description)}
            |${(for (b <- l.content) yield renderBlock(b), "\n")}
            |${(for (sl <- l.subLevels) yield renderLevel(sl, pos + 1), "\n")}""")
    }

    val content = renderLevel(level, 0)
    readmeLoc.writeOver(content.render)
    println(s"Wrote: ${readmeLoc}")
  }


  def genReport(project: Project, packageName: String, aadlRootDir: Os.Path, rootDir: Os.Path, reporter: Reporter): Level = {
    return Report(packageName, aadlRootDir, repoRootDir).genReport(project)
  }

  def createLinkFromPos(text: String, pos: Position,
                        aadlDir: Os.Path, rootDir: Os.Path): ST = {
    val ret: ST = pos match {
      case org.sireum.message.FlatPos(Some(uriOpt), beginLine, _, _, _, _, _) =>
        val sops = ops.StringOps(uriOpt)
        assert(sops.startsWith("/"))
        val pos = sops.indexOfFrom('/', 1)
        val stripped = sops.substring(pos, sops.size)
        val uri = aadlDir / stripped

        val line = conversions.U32.toZ(beginLine)
        st"[${text}](${rootDir.relativize(uri).value}#L${line})"

      case _ => halt(s"Infeasible: not a FlatPos - ${pos}")
    }
    return ret
  }

  def createClassifierLink(textToDisplay: String, componentType: String, classifier: Classifier, aadlDir: Os.Path, rootDir: Os.Path): ST = {
    val name = ops.StringOps(ops.StringOps(classifier.name).replaceAllLiterally("::", ":")).split(c => c == ':')
    val file = Os.Path.walk(aadlDir, T, F, p => p.isFile && ops.StringOps(p.read).contains(s"package ${name(0)}"))(0)
    val cType: String =
      if (ops.StringOps(name(1)).contains(".")) s"${componentType} implementation"
      else componentType
    val lines = file.readLines
    for(i <- 0 until lines.size if ops.StringOps(lines(i)).contains(s"${cType} ${name(1)}")) {
      return st"[${textToDisplay}](${rootDir.relativize(file).value}#L${i + 1})"
    }
    halt(s"Infeasible: couldn't find $cType in $file")
  }

  def sortThreads(threads: ISZ[AadlThread], symbolTable: SymbolTable): ISZ[AadlThread] = {
    return (
      ops.ISZOps(threads()).sortWith((a,b) => a.component.classifier.get.name < b.component.classifier.get.name))
  }

  def createHyperLink(title: String, target: String): ST = {
    return st"[${title}](${target})"
  }

  def createTag(s: String): String = {
    val lc = StringUtil.toLowerCase(s)
    val d = StringUtil.replaceAll(lc, " ", "-")
    val cis = conversions.String.toCis(d)

    // only keep numbers, lowercase letters, '-' and '_'
    val cis_ = cis.filter(c =>
      (c.value >= 48 && c.value <= 57) || (c.value >= 97 && c.value <= 122) ||
        (c == '-') || (c == '_'))
    val d_ = conversions.String.fromCis(cis_)
    return d_
  }

  def toGithubLink(s: String): String = {
    return s"#${createTag(s)}"
  }

  def splitClassifier(c: AadlComponent): (String, String) = {
    val o = ops.StringOps(ops.StringOps(c.component.classifier.get.name).replaceAllLiterally("::", ":")).split(c => c == ':')
    return (o(0), o(1))
  }

  def sanitize(s: String) : String = {
    return ops.StringOps(s).replaceAllLiterally(".", "_")
  }

  def findMethod(key: String, f: Os.Path): Z = {
    assert(f.isFile, s"$f is not a file")
    assert(!ops.StringOps(f.read).contains("\r"), s"$f contains windows style new lines")

    var line = 1
    // add space before newline as split does not preserve empty lines (i.e. those that only contain newline char)
    for (l <- ops.StringOps(ops.StringOps(f.read).replaceAllLiterally("\n", " \n")).split(c => c == '\n')) {
      if (ops.StringOps(l).contains(s"def $key(api: ")) {
        return line
      }
      line = line + 1
    }
    halt(s"Infeasible, didn't find $key in $f")
  }

}

import Report._

@datatype class Report(packageName: String, aadlRootDir: Os.Path, repoRoot: Os.Path) {

  def genReport(project: Project): Level = {

    val model = AadlModelUtil.getModel(project.air, F)
    val table = AadlModelUtil.getSymbolTable(model, packageName, project.configs(0))

    val arch = genArchitectureSection(project, table)

    val logika = genLogikaSection(project, table)

    return Level(
      tag = "",
      title = Some(st"${project.title}"),
      description = None(),
      content = ISZ(),
      subLevels = ISZ(arch, logika)
    )
  }


  def collect(index: Z, content: ISZ[ISZ[String]]): Z = {
    var sum: Z = 0
    for (c <- content) {
      sum = sum + Z(c(index)).get
    }
    return sum / content.size
  }

  def allSame(index: Z, content: ISZ[ISZ[String]]): Unit = {
    var last: Z = -1
    for (c <- content) {
      if (last == -1) {
        last = Z(c(index)).get
      } else {
        assert(Z(c(index)).get == last)
      }
    }
  }

  def formatTime(s: Z): String = {
    val cis = conversions.String.toCis(s.string)
    var ret: ISZ[org.sireum.C] = ISZ()
    for(ix <- cis.size -1 to 0 by -1) {
      ret = cis(ix) +: ret
      if (ret.size == 3){
        ret = '.' +: ret
      }
    }
    val r :String = conversions.String.fromCis(ret)
    return if(ret.size == 2) s"0.0$r"
    else if(ret.size == 3) s"0.$r"
    else if (ret.size == 4) s"0$r"
    else r
  }

  def processResults(csv: Os.Path): HashSMap[String, ST] = {

    val rawlines = csv.readLines
    assert (rawlines(0) == "entrypoint,cliTime,logikaTime,processBegin,processCheck,vcsNum,vcsTime,satNum,satTime,timeStamp,kekikianBuild,timeout,rlimit,par,par-branch,par-branch-mode,System Version,Computer Name,Model Identifier,Processor,Memory")
    val lines: ISZ[ISZ[String]] = for (l <- ops.ISZOps(rawlines).drop(1)) yield ops.StringOps(l).split(c => c == ',')

    var entrypoints : Set[String] = Set.empty
    for(l <- lines) {
      entrypoints = entrypoints + l(0)
    }
    var ret = HashSMap.empty[String, ST]
    for(entryPoint <- entrypoints.elements) {
      val entries = ops.ISZOps(lines).filter(p => p(0) == entryPoint)
      val cliTime = collect(1, entries)
      val logikaTime = collect(2, entries)
      val processBegin = collect(3, entries)
      val processCheck = collect(4, entries)
      val vcsNum = collect(5, entries)
      allSame(5, entries)
      val vcsTime = collect(6, entries)
      val satNum = collect(7, entries)
      allSame(7, entries)
      val satTime = collect(8, entries)

      val ttime = formatTime(logikaTime)
      val itctime = formatTime(processBegin - processCheck)
      val vtime = formatTime(processCheck)


      ret = ret + entryPoint ~> st"|$vcsNum|$satNum|$ttime|$itctime|$vtime|"
    }
    return ret
  }

  def genLogikaSection(project: ReadmeGen.Project, table: SymbolTable): Level = {
    var subLevels:ISZ[Block] = ISZ()
    for(t <- table.getThreads()) {
      val cimplname: String = sanitize(splitClassifier(t)._2)
      val sp = st"${(ops.ISZOps(t.path).drop(1), "_")}".render
      val fnamePrefix: String = s"${cimplname}_${sp}"
      val scalaFilename = s"${fnamePrefix}.scala"

      val csvFilename = s".${scalaFilename}.csv"

      val componentDir = Os.path(project.configs(0).outputDir.get) / "src" / "main" / "component" / project.configs(0).packageName.get
      val csvFile = Os.Path.walk(componentDir, T, F, p => p.name == csvFilename)
      val scalaFile = Os.Path.walk(componentDir, T, F, p => p.name == scalaFilename)(0)

      if (csvFile.nonEmpty) {
        val tag = s"logika-${fnamePrefix}"
        var entries: ISZ[ST] = ISZ()
        for(r <- processResults(csvFile(0)).entries) {
          val lineNum = findMethod(r._1, scalaFile)
          val elink = st"[${r._1}](${project.projectRootDir.relativize(scalaFile)}#L${lineNum})"
          entries = entries :+ st"|${elink}${r._2}"
        }
        val table =
          st"""
              |**${t.identifier}**
              |
              |Raw Data: [csv](${project.projectRootDir.relativize(csvFile(0))})
              |
              |EntryPoint|VC|SAT|TTime|ITCTime|VTime|
              ||--|--|--|--|--|--|
              |${(entries, "\n")}"""

        subLevels = subLevels :+ Block(
          tag = tag,
          content = Some(table)
        )/*
        subLevels = subLevels :+ Level(
          tag = tag,
          title = Some(st"${t.identifier}"),
          description = None(),
          content = ISZ(Block(s"${tag}-table", Some(table))),
          subLevels = ISZ()
        )*/
      }
    }

    val results = Level(
      tag = "logiak-results",
      title = Some(st"Results"),
      description = None(),
      content = subLevels,
      subLevels = ISZ()
    )
    val slashScript = repoRoot / "bin" / "report-logika.cmd"
    val relSlashScript = project.projectRootDir.relativize(slashScript)

    val howToRun = Level(
      tag = "how-to-run",
      title = Some(st"How to replicate"),
      description = Some(st"""To run the experiments, first install Sireum Kekinian (optionally choosing the
                             |commit tip used for the experiments, ie. [843ede1](https://github.com/sireum/kekinian/tree/843ede1120e6e75fde089db0928ab66a3c9a3e73))
                             |
                             |```
                             |git clone --rec https://github.com/sireum/kekinian.git
                             |cd kekinian
                             |git checkout 843ede1
                             |git pull --rec
                             |bin/build.cmd
                             |
                             |export SIREUM_HOME=$$(pwd)
                             |export PATH=$$SIREUM_HOME/bin:$$PATH
                             |```
                             |
                             |Then run the following Slash script specifying the number of number of times to rerun Logika
                             |on each entrypoint: [${relSlashScript}](${relSlashScript})
                             |
                             |```
                             |${relSlashScript} run 25
                             |```
                             |
                             |The results will be appended to the csv file corresponding to the component
                             |being evaluated. The line ``val projects: Map[String, Project] = Map.empty + isolette + rts + tcP + tcS``
                             |in the script can be modified if you want to run a subset of the projects"""),
      content = ISZ(), subLevels = ISZ()
    )

    return Level(
      tag = "logika",
      title = Some(st"Logika"),
      description = Some(
        st"""<script type="text/javascript"
            |  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_CHTML">
            |</script>
            |<script type="text/x-mathjax-config">
            |  MathJax.Hub.Config({
            |    tex2jax: {
            |      inlineMath: [['$$','$$'], ['\\(','\\)']],
            |      processEscapes: true},
            |      jax: ["input/TeX","input/MathML","input/AsciiMath","output/CommonHTML"],
            |      extensions: ["tex2jax.js","mml2jax.js","asciimath2jax.js","MathMenu.js","MathZoom.js","AssistiveMML.js", "[Contrib]/a11y/accessibility-menu.js"],
            |      TeX: {
            |      extensions: ["AMSmath.js","AMSsymbols.js","noErrors.js","noUndefined.js"],
            |      equationNumbers: {
            |      autoNumber: "AMS"
            |      }
            |    }
            |  });
            |</script>
            |The following reports the experimental data obtained by running Logika
            |only on the component entrypoints that require verification (e.g. TempControl's
            |Fan component was excluded as it does not contain GUMBO contracts and does not
            |use datatypes that have invariants).  Logika was configured with a 2 second
            |validity checking timeout, a 500 millisecond satisfiability checking timeout, a
            |SMT2 resource limit of 2,000,000, and with full parallelization optimizations
            |enabled.  The SMT2 solvers used include CVC4 1.8, CVC5 1.0.5, and Z3 4.12.2. The
            |$${\bf VC}$$ and $${\bf SAT}$$ columns report the number of verification and
            |satisfiability conditions that were checked, respectively.  The time values
            |reported in the final three columns are the averages obtained after re-running
            |Logika 25 times for each entrypoint on an M1 Mac Mini with 8 cores and 16 GB of
            |RAM.  $${\bf TTime}$$ gives the total number of seconds it took to run Logika
            |from the command line on the Slang project containing the entrypoint (i.e. it
            |includes the verification time along with the time required for parsing, type
            |checking, etc.).
            |
            |One optimization technique related to using Logika from within IVE that can be
            |measured via our experimental setup is Sireum's incremental type checking. For
            |example, if Logika was run on the Isolette MA component's initialize entrypoint
            |from within IVE using an identical configuration as was done for the experiments
            |then it will take on average 2.482 seconds to verify, assuming Logika had not
            |previously been invoked.  If a change was then made to MA's source code before
            |re-running Logika on the timeTriggered entrypoint then Sireum's incremental type
            |checking will only need to recheck MA (and any of its dependents) resulting in
            |an average delay of only 0.214 seconds before verification can proceed. The
            |results of these optimizations are reported in the Incremental-Type Checking
            |column ($${\bf ITCTime}$$).  The time required to actually verify an entrypoint with
            |a clean cache is reported in the Verification-Time column ($${\bf VTime}$$) so
            |incremental type checking for this example would save 2.268 seconds (2.482 -
            |0.214) on average."""),
      content = ISZ(),
      subLevels = ISZ(results, howToRun)
    )
  }

  def genArchitectureSection(project: Project, table: SymbolTable): Level = {

    var blocks: ISZ[Block] = ISZ()

    AadlModelUtil.getAadlArchDiagram(aadlRootDir) match {
      case Some(p) =>
        val rootDir = project.projectRootDir
        val rel = rootDir.relativize(p)
        val link = createHyperLink("AADL Arch", rel.value)
        blocks = blocks :+ Block("aadl-arch-diagram", Some(st"!${link}"))
      case _ =>
    }

    val tagPrefix = "aadl-arch-component-info"

    val header: ST =
      createClassifierLink(table.rootSystem.identifier,
        "system", table.rootSystem.component.classifier.get, aadlRootDir, project.projectRootDir)

    var systemProps =
      st"""|System: ${header} |
           ||--|"""


    if (table.rootSystem.getUseRawConnection()) {
      systemProps =
        st"""${systemProps}
            ||Wire Protocol|"""
    }
    blocks = blocks :+ Block(s"${tagPrefix}-${table.rootSystem.identifier}", Some(systemProps))

    val threads: ISZ[AadlThread] = sortThreads(table.getThreads(), table)
    for (thread <- threads) {
      val name = thread.identifier
      val typ: String =
        if (thread.isPeriodic()) s"Periodic: ${thread.period.get} ms"
        else "Sporadic"

      val compType: Option[String] =
        if (thread.isCakeMLComponent()) Some("||CakeML|")
        else if (thread.getParent(table).toVirtualMachine(table)) Some("||Virtual Machine|")
        else None()//"Native"

      val domain: Option[ST] = if (thread.getParent(table).getDomain(table).nonEmpty) {
        Some(st"""|Domain: ${thread.getParent(table).getDomain(table).get}|""")
      } else {
        None()
      }

      val header: ST = {
        val pos: Position = thread.component.identifier.pos.get
        createLinkFromPos(name, pos, aadlRootDir, project.projectRootDir)
      }

      val classifierLink = createClassifierLink(
        thread.component.classifier.get.name,"thread",
        thread.component.classifier.get, aadlRootDir, project.projectRootDir)

      blocks = blocks :+ Block(
        s"${tagPrefix}-${thread.identifier}",
        Some(
          st"""|Thread: ${header} |
               ||--|
               ||Classifier: ${classifierLink}|
               ${compType}
               ||${typ}|
               |${domain}
               |"""))
    }

    /*
      val proc: AadlProcessor = PeriodicUtil.getBoundProcessor(symbolTable)
      proc.getScheduleSourceText() match {
        case Some(loc) =>
          val schedule = Os.path(report.options.aadlRootDir.get) / loc
          assert(schedule.exists, schedule.canon)
          content =
            st"""$content
                |
                |**Schedule:** [${schedule.name}](${report.readmeDir.relativize(schedule).value})"""
        case _ =>
      }
    */

    return Level(
      tag = "arch-section",
      title = Some(st"AADL Architecture"),
      description = None(),
      content = blocks,
      subLevels = ISZ()
    )
  }
}