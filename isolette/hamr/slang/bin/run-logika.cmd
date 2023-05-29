::/*#! 2> /dev/null                                 #
@ 2>/dev/null # 2>nul & echo off & goto BOF         #
if [ -z ${SIREUM_HOME} ]; then                      #
  echo "Please set SIREUM_HOME env var"             #
  exit -1                                           #
fi                                                  #
exec ${SIREUM_HOME}/bin/sireum slang run "$0" "$@"  #
:BOF
setlocal
if not defined SIREUM_HOME (
  echo Please set SIREUM_HOME env var
  exit /B -1
)
%SIREUM_HOME%\\bin\\sireum.bat slang run "%0" %*
exit /B %errorlevel%
::!#*/
// #Sireum

import org.sireum._

val homeBin = Os.slashDir
val home = homeBin.up

val monitorDir = home / "src" / "main" / "component" / "isolette" / "Monitor"
val regulateDir = home / "src" / "main" / "component" / "isolette" / "Regulate"

val sireumBin = Os.path(Os.env("SIREUM_HOME").get) / "bin" 
val sireum = sireumBin / (if(Os.isWin) "sireum.bat" else "sireum")

val collectStats = T

val ignoreStringInterpWarnings: B = T // if T then ignore string interp warnings as the strings only appear in api.logInfo calls and not in contracts

val isCi: B = Os.env("GITLAB_CI").nonEmpty || Os.env("GITHUB_ACTIONS").nonEmpty || Os.env("BUILD_ID").nonEmpty

val initialisePrefix = "initialise"
val timeTriggeredPrefix = "timeTriggered"

@datatype class ExpectedReport(val expectedWarnings: ISZ[String],
                               val expectedErrors: ISZ[String])
val emptyReport = ExpectedReport(ISZ(), ISZ())

val emptyMap = Map.empty[String, ExpectedReport] + (initialisePrefix ~> emptyReport) + (timeTriggeredPrefix ~> emptyReport)

@datatype class LogikaOpt (val timeout: Z,
                           val rlimit: Z)

val defaultOpts = LogikaOpt(timeout = (if(isCi) 10 else 2), rlimit = 2000000)

@datatype class C(val file: Os.Path,
                  val logikaOpts: LogikaOpt,
                  val expectedReports: Map[String, ExpectedReport])

val files = ISZ[C](

  C(monitorDir / "Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala", defaultOpts, emptyMap),

  C(monitorDir / "Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala", defaultOpts, emptyMap),

  C(monitorDir / "Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala", defaultOpts, emptyMap),

  C(regulateDir / "Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala", defaultOpts, emptyMap),

  C(regulateDir / "Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala", defaultOpts, emptyMap),

  C(regulateDir / "Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala", defaultOpts, emptyMap)
)

println("Initializing runtime library ...\n")
Sireum.initRuntimeLibrary()

var result: Z = 0
for(f <- files;
    entryPoint <- ISZ(initialisePrefix, timeTriggeredPrefix)) {

  val reporter = org.sireum.message.Reporter.create
  var input = ISZ[String]("proyek", "logika",
    "--timeout", f.logikaOpts.timeout.string, //
    "--rlimit", f.logikaOpts.rlimit.string, //
    "--par",
    "--par-branch",
    "--par-branch-mode", "all",
    "--line", findMethod(entryPoint, f.file).string)

  if(collectStats) {
    input = input :+ "--stats"
    input = input :+ "--log-detailed-info"
  }

  input = input :+ home.value :+ f.file.value

  println(s"Checking $entryPoint method of ${f.file.name}")
  println(st"$sireum ${(input, " ")}".render)

  val start = org.sireum.extension.Time.currentMillis
  val results = Sireum.runWithReporter(input, reporter)

  val _elapsed = org.sireum.extension.Time.currentMillis - start
  val elapsed = s"in ${_elapsed} ms"

  var report =  ISZ[String]()

  def compare(typ: String, expected: ISZ[String], actual: ISZ[message.Message]): Unit = {
    if (expected.size != actual.size) {
      report = report :+ s"  Was expecting ${expected.size} ${typ}s but encountered ${actual.size}"
    }
    @strictpure def m2s(m: message.Message): String = s"[${m.posOpt.get.beginLine}, ${m.posOpt.get.beginColumn}] ${m.text}"
    for (m <- actual if !ops.ISZOps(expected).exists(p => p == m2s(m))) {
      report = report :+ s"  Unexpected $typ: ${m2s(m)}"
    }
  }

  compare("warning", f.expectedReports.get(entryPoint).get.expectedWarnings, reporter.warnings.filter(p =>
    !ignoreStringInterpWarnings || !ops.StringOps(p.text).contains("String interpolation is currently over-approximated to produce an unconstrained string")))
  compare("error", f.expectedReports.get(entryPoint).get.expectedErrors, reporter.errors)

  if (report.nonEmpty) {
    println(s"*** Failed ***\n")
    println(st"${(report, "\n")}\n".render)
    result = 1
  } else {
    println(s"  Everything accounted for:")
  }
  println(s"  Verification ${if(results._1 == 0) s"succeeded $elapsed!" else s"failed $elapsed"}\n")

  def writeToResults(key: String, value: String): Unit = {
    val lresults = f.file.up / s".${f.file.name}.${entryPoint}.properties"
    var props: Map[String, String] = if (!lresults.exists)
      Map.empty[String, String]
    else lresults.properties

    props = props + key ~> value
    val entries: ISZ[String] = ops.ISZOps(for (e <- props.entries) yield st"${e._1}=${e._2}".render).sortWith((a,b) => a < b)
    lresults.writeOver(st"${(entries, "\n")}".render)
  }

  writeToResults("cliTime", _elapsed.string)

  if(collectStats) {
    def split(s: String): (Z, Z) = {
      println(s)
      val ss = ops.StringOps(s)
      val num = Z(ss.substring(ss.indexOf(':') + 2, ss.indexOf('(') - 1)).get

      val time = ops.StringOps(ss.substring(ss.stringIndexOf("(time: ") + 7, s.size - 1))
      if (time.endsWith("s")) {
        // (time 14.342s)
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
    val o = ops.ISZOps(ops.StringOps(results._2).split(c => c == '\n'))
    val vcs = o.filter(f => ops.StringOps(f).contains("Number of SMT2 ver"))(0)
    val sats = o.filter(f => ops.StringOps(f).contains("Number of SMT2 sat"))(0)
    val (vcNum, vcTime) = split(vcs)
    val (sNum, sTime) = split(sats)

    writeToResults("vcsNum", vcNum.string)
    writeToResults("vcsTime", vcTime.string)
    writeToResults("satNum", sNum.string)
    writeToResults("satTime", sTime.string)
  }
}

Os.exit(result)

def findMethod(key: String, f: Os.Path): Z = {
  assert(f.isFile, s"$f is not a file")
  assert(!ops.StringOps(f.read).contains("\r"), s"$f contains windows style new lines")

  var line = 1
  // add space before newline as split does not preserve empty lines (i.e. those that only contain newline char)
  for(l <- ops.StringOps(ops.StringOps(f.read).replaceAllLiterally("\n", " \n")).split(c => c == '\n')) {
    if (ops.StringOps(l).contains(s"def $key(api: ")) {
      return line
    }
    line = line + 1
  }
  halt(s"Infeasible, didn't find $key in $f")
}
