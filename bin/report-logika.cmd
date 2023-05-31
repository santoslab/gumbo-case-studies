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

val sireumBin = Os.path(Os.env("SIREUM_HOME").get) / "bin"
val sireum = sireumBin / (if (Os.isWin) "sireum.bat" else "sireum")

val collectStats = T
val par: B = T
val parBranch: B = T
val parMode: String = "all"

val ignoreStringInterpWarnings: B = T // if T then ignore string interp warnings as the strings only appear in api.logInfo calls and not in contracts

val isCi: B = Os.env("GITLAB_CI").nonEmpty || Os.env("GITHUB_ACTIONS").nonEmpty || Os.env("BUILD_ID").nonEmpty

val initialisePrefix = "initialise"
val timeTriggeredPrefix = "timeTriggered"

@datatype class ExpectedReport(val expectedWarnings: ISZ[String],
                               val expectedErrors: ISZ[String])
val emptyReport = ExpectedReport(ISZ(), ISZ())

val periodicMap = Map.empty[String, ExpectedReport] + (initialisePrefix ~> emptyReport) + (timeTriggeredPrefix ~> emptyReport)
val sporadicMap = Map.empty[String, ExpectedReport] + (initialisePrefix ~> emptyReport)

@datatype class LogikaOpt(val timeout: Z,
                          val rlimit: Z)

val defaultOpts = LogikaOpt(timeout = (if (isCi) 10 else 2), rlimit = 2000000)

@datatype class Project(val rootDir: Os.Path,
                        val title: String,
                        val description: String,
                        val containers: ISZ[C])

@datatype class C(val componentShortName: String,
                  val file: Os.Path,
                  val logikaOpts: LogikaOpt,
                  val expectedReports: Map[String, ExpectedReport])


val isoletteHome = home / "isolette"
val monitorDir = isoletteHome / "hamr" / "slang" / "src" / "main" / "component" / "isolette" / "Monitor"
val regulateDir = isoletteHome / "hamr" / "slang" / "src" / "main" / "component" / "isolette" / "Regulate"
val isolette = "isolette" ~>
  Project(isoletteHome, "Isolette", "Isolette", ISZ(
    C("MA", monitorDir / "Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala", defaultOpts, periodicMap),
    C("MMI", monitorDir / "Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala", defaultOpts, periodicMap),
    C("MMM", monitorDir / "Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala", defaultOpts, periodicMap),
    C("MHS", regulateDir / "Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala", defaultOpts, periodicMap),
    C("MRI", regulateDir / "Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala", defaultOpts, periodicMap),
    C("MRM", regulateDir / "Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala", defaultOpts, periodicMap)))

val rtsHome = home / "rts"
val actuationDir = rtsHome / "hamr" / "slang" / "src" / "main" / "component" / "RTS" / "Actuation"
val rts = "rts" ~>
  Project(rtsHome, "RTS", "RTS", ISZ(
    C("SaturationActuator", actuationDir / "Actuator_i_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator.scala", defaultOpts, periodicMap),
    C("TempPressureActuator", actuationDir / "Actuator_i_actuationSubsystem_tempPressureActuatorUnit_tempPressureActuator_actuator.scala", defaultOpts, periodicMap),
    C("AU1\\_PressureLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_pressureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU1\\_SaturationLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_saturationLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU1\\_TemperatureLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_temperatureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU2\\_PresureLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_pressureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU2\\_SaturationLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_saturationLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU2\\_SaturationLogic", actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_temperatureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C("AU1\\_TempPressureTripOut", actuationDir / "OrLogic_i_actuationSubsystem_actuationUnit1_tempPressureTripOut_orLogic.scala", defaultOpts, periodicMap),
    C("AU2\\_TempPressureTripOut", actuationDir / "OrLogic_i_actuationSubsystem_actuationUnit2_tempPressureTripOut_orLogic.scala", defaultOpts, periodicMap),
    C("OrLogic\\_SaturationActuator", actuationDir / "OrLogic_i_actuationSubsystem_saturationActuatorUnit_actuateSaturationActuator_orLogic.scala", defaultOpts, periodicMap),
    C("OrLogic\\_TempPressureActuator", actuationDir / "OrLogic_i_actuationSubsystem_tempPressureActuatorUnit_actuateTempPressureActuator_orLogic.scala", defaultOpts, periodicMap)))

val tcPHome = home / "temp_control" / "periodic"
val tcPDir = tcPHome / "hamr" / "slang" / "src" / "main" / "component" / "tc"
val tcP = "tcPeriodic" ~>
  Project(tcPHome, "TCP", "TempControl Periodic", ISZ[C](
    C("TempControl", tcPDir / "TempControlSoftwareSystem" / "TempControlPeriodic_p_tcproc_tempControl.scala", defaultOpts, periodicMap),
    C("TempSensor", tcPDir / "TempSensor" / "TempSensorPeriodic_p_tcproc_tempSensor.scala", defaultOpts, periodicMap),
  ))

val tcSHome = home / "temp_control" / "sporadic"
val tcSDir = tcSHome / "hamr" / "slang" / "src" / "main" / "component" / "tc"
val tcS = "tcSporadic" ~>
  Project(tcSHome, "TempControl", "TempControl Sporadic", ISZ[C](
    C("TempControl", tcSDir / "TempControlSoftwareSystem" / "TempControl_s_tcproc_tempControl.scala", defaultOpts,
      sporadicMap + ("handle_fanAck" ~> emptyReport) + ("handle_setPoint" ~> emptyReport) + ("handle_tempChanged" ~> emptyReport)),
    C("TempSensor", tcSDir / "TempSensor" / "TempSensor_s_tcproc_tempSensor.scala", defaultOpts, periodicMap)))

val projects: Map[String, Project] = Map.empty + isolette + rts + tcP + tcS

val systemVersion = "System Version"
val compName = "Computer Name"
val modelId = "Model Identifier"
val processor = "Processor"
val memory = "Memory"

val sysInfo = getSystemInfo

def run: Z = {

  if (Os.cliArgs.size != 2) {
    println("Must specify the number of runs")
    Os.exit(-1)
  }

  val numRuns: Z = Z(Os.cliArgs(1)).get
  println(s"Starting $numRuns runs")

  println("Initializing runtime library ...\n")
  Sireum.initRuntimeLibrary()

  var result: Z = 0
  val runsStart = org.sireum.extension.Time.currentMillis
  for (run <- 0 until numRuns) {
    val runStart = org.sireum.extension.Time.currentMillis
    for (project <- projects.entries) {
      println(s"Processing ${project._1} ...")
      for (f <- project._2.containers) {
        val csv = f.file.up / s".${f.file.name}.csv"
        if (!csv.exists) {
          csv.writeOver(s"entrypoint,cliTime,logikaTime,processBegin,processCheck,vcsNum,vcsTime,satNum,satTime")
          csv.writeAppend(s",timeStamp,kekikianBuild,timeout,rlimit,par,par-branch,par-branch-mode")
          csv.writeAppend(s",$systemVersion,$compName,$modelId,$processor,$memory\n")
        }

        for (entryPoint <- f.expectedReports.keys) {

          val reporter = org.sireum.message.Reporter.create
          var input = ISZ[String]("proyek", "logika",
            "--timeout", f.logikaOpts.timeout.string, //
            "--rlimit", f.logikaOpts.rlimit.string, //
            "--par",
            "--par-branch",
            "--par-branch-mode", "all",
            "--line", findMethod(entryPoint, f.file).string)

          if (collectStats) {
            input = input :+ "--stats"
            input = input :+ "--log-detailed-info"
          }

          input = input :+ (project._2.rootDir / "hamr" / "slang").value :+ f.file.value

          println(s"Checking $entryPoint method of ${f.file.name}")
          println(st"$sireum ${(input, " ")}".render)

          val start = org.sireum.extension.Time.currentMillis
          val results = Sireum.runWithReporter(input, reporter)

          val _elapsed = org.sireum.extension.Time.currentMillis - start
          val elapsed = s"in ${_elapsed} ms"

          var report = ISZ[String]()

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
          println(s"  Verification ${if (results._1 == 0) s"succeeded $elapsed!" else s"failed $elapsed"}\n")

          if (collectStats) {
            val o = ops.ISZOps(ops.StringOps(results._2).split(c => c == '\n'))

            def parseTime(_time: String): Z = {
              println(_time)
              val time = ops.StringOps(_time)
              val millis = Z(time.substring(time.indexOf('.') + 1, time.size)).get
              if (time.indexOf(':') >= 0) {
                val minAsMs = Z(time.substring(0, time.indexOf(':'))).get * 60000
                val secAsMs = Z(time.substring(time.indexOf(':') + 1, time.indexOf('.'))).get * 1000
                return minAsMs + secAsMs + millis
              } else {
                val minAsMs = Z(time.substring(0, time.indexOf('.'))).get * 1000
                return minAsMs + millis
              }
            }

            def getTime(s: String): Z = {
              println(s)
              val ss = ops.StringOps(ops.StringOps(s).trim)
              val time = ops.StringOps(ss.substring(ss.stringIndexOf("time: ") + 6, ss.size - 1))
              return (
                if (time.endsWith("s")) parseTime(time.substring(0, time.size - 1))
                else parseTime(time.s))
            }

            def split(key: String): (Z, Z) = {
              if (o.filter(f => ops.StringOps(f).contains(key)).isEmpty) {
                return (0, 0)
              } else {
                val ss = ops.StringOps(o.filter(f => ops.StringOps(f).contains(key))(0))
                val num = Z(ss.substring(ss.indexOf(':') + 2, ss.indexOf('(') - 1)).get
                return (num, getTime(ss.substring(0, ss.size - 1)))
              }
            }

            val (vcsNum, vcsTime) = split("Number of SMT2 verification condition checking")
            val (satNum, satTime) = split("Number of SMT2 satisfiability checking")
            val logikaTime = getTime(o.filter(f => ops.StringOps(f).contains("Logika verified! Elapsed time:"))(0))
            val hbeginTime = getTime(o.filter(f => ops.StringOps(f).contains("Process Method Begin"))(0))
            val hcheckTime = getTime(o.filter(f => ops.StringOps(f).contains("Process Method Just"))(0))

            csv.writeAppend(s"$entryPoint,${_elapsed},$logikaTime,$hbeginTime,$hcheckTime,$vcsNum,$vcsTime,$satNum,$satTime")
            csv.writeAppend(s",$start,${SireumApi.version},${f.logikaOpts.timeout.string},${f.logikaOpts.rlimit.string},$par,$parBranch,$parMode")
            csv.writeAppend(s",${sysInfo.get(systemVersion).get},${sysInfo.get(compName).get},${sysInfo.get(modelId).get},${sysInfo.get(processor).get},${sysInfo.get(memory).get}\n")
            println()
          }
        }
      }
    }
    val runElapsed = org.sireum.extension.Time.currentMillis - runStart
    println(s"Run $run took ${runElapsed} ms")
  }
  val runsElapsed = org.sireum.extension.Time.currentMillis - runsStart
  println(s"$numRuns runs took ${runsElapsed} ms")

  return result
}

def report: Unit = {
  if (Os.cliArgs.size != 2) {
    println("Specify path to latex output file")
    Os.exit(-1)
  }
  val outputFile = Os.path(Os.cliArgs(1))

  def collect(index: Z, content: ISZ[ISZ[String]]): Z = {
    var sum: Z = 0
    for(c <- content) {
      sum = sum + Z(c(index)).get
    }
    return sum / content.size
  }

  def allSame(index: Z, content: ISZ[ISZ[String]]): Unit = {
    var last: Z = -1
    for(c <- content) {
      if (last == -1) {
        last = Z(c(index)).get
      } else {
        assert (Z(c(index)).get == last)
      }
    }
  }

  var entries: ISZ[ST] = ISZ()
  for (project <- projects.entries) {
    println(s"Processing ${project._2.title} ...")
    var rows: ISZ[ST] = ISZ()

    val numRows = {
      var i: Z = 2
      for (c <- project._2.containers) {
        i = i + c.expectedReports.entries.size
      }
      i
    }
    for (f <- project._2.containers) {
      val csv = f.file.up / s".${f.file.name}.csv"
      val lines = for (l <- csv.readLines) yield ops.StringOps(l).split(c => c == ',')
      println(s"  $csv")

      val entrypoints = f.expectedReports.keys.size

      for (entryPoint <- f.expectedReports.keys) {
        println(s"    $entryPoint")

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

        //val numEntries = components * entrypoints
        val eentryPoint = ops.StringOps(entryPoint).replaceAllLiterally("_", "\\_")
        //println(s"      $cliTime $logikaTime $processBegin $processCheck $vcsNum $vcsTime $satNum $satTime")
        val row = st"""& {\bf ${f.componentShortName}.${eentryPoint}} & $vcsNum & $satNum & $processBegin & $processCheck & $logikaTime \\
                      |\cline{2-7}"""
        rows = rows :+ row
      }
    }

    val entry =
      st"""\multirow{${rows.size}}{*}
          |{\begin{sideways}{\sf ${project._2.title}}\end{sideways}}
          |${(rows, "\n")}
          |\hline
          |"""
    entries = entries :+ entry
  }

  val table =st"""\begin{table*}[t]
                 |%\vspace*{-2mm}
                 |{\scriptsize
                 |  \begin{tabular}{|l|l|r|r|r|r|r|}
                 |  \hline
                 |  %\multicolumn{1}{>{\columncolor[gray]{0}}l}{\textcolor{white}{\bf System}}&
                 |  \multicolumn{2}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf EntryPoint}} &
                 |  \multicolumn{1}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf VC}} &
                 |  \multicolumn{1}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf SAT}} &
                 |  \multicolumn{1}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf VTime1}} &
                 |  \multicolumn{1}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf VTime2}} &
                 |  \multicolumn{1}{>{\columncolor[gray]{0}}c}{\textcolor{white}{\bf TTime}}
                 |  \\
                 |  \hline
                 |  ${(entries, "\n")}
                 |  \end{tabular}
                 |}
                 |\caption{Experiment Data Excerpts}
                 |\label{tab:data}
                 |\end{table*}
                 |"""
  outputFile.writeOver(table.render)
  println(s"Wrote $outputFile")
}



if (Os.cliArgs.isEmpty) {
  println("Choose an option (run | report)")
  Os.exit(0)
}

Os.cliArgs(0) match {
  case string"run" => run
  case string"report" => report
  case _ => halt("Not a valid option")
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

def getSystemInfo: Map[String, String] = {
  if (Os.isMac) {
    val info = ops.ISZOps(for (l <- ops.StringOps(proc"system_profiler SPSoftwareDataType SPHardwareDataType".runCheck().out).split(c => c == '\n')) yield ops.StringOps(ops.StringOps(l).trim).split(c => c == ':'))

    @strictpure def f(key: String): (String, String) = (key, ops.StringOps(ops.StringOps(info.filter(p => p(0) == key)(0)(1)).trim).replaceAllChars(',', '_'))

    val processorVal =
      if (Os.prop("os.arch").get == "aarch64") {
        val chip = f("Chip")
        val cores = f("Total Number of Cores")
        s"${chip._2} ${cores._2}"
      } else {
        val name = f("Processor Name")
        val speed = f("Processor Speed")
        s"${name._2} ${speed._2}"
      }
    return Map.empty[String, String] + f(systemVersion) + f(compName) + f(modelId) + processor ~> processorVal + f(memory)
  } else {
    halt("TODO")
  }
}