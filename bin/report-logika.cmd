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

if (Os.cliArgs.size != 1) {
  println("Must specify the number of runs")
  Os.exit(-1)
}

val numRuns: Z = Z(Os.cliArgs(0)).get

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

@datatype class C(val file: Os.Path,
                  val logikaOpts: LogikaOpt,
                  val expectedReports: Map[String, ExpectedReport])


val isoletteHome = home / "isolette"
val monitorDir = isoletteHome / "hamr" / "slang" / "src" / "main" / "component" / "isolette" / "Monitor"
val regulateDir = isoletteHome / "hamr" / "slang" / "src" / "main" / "component" / "isolette" / "Regulate"
val isolette = "isolette" ~>
  Project(isoletteHome, "Isolette", "Isolette", ISZ(
    C(monitorDir / "Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala", defaultOpts, periodicMap),
    C(monitorDir / "Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala", defaultOpts, periodicMap),
    C(monitorDir / "Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala", defaultOpts, periodicMap),
    C(regulateDir / "Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala", defaultOpts, periodicMap),
    C(regulateDir / "Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala", defaultOpts, periodicMap),
    C(regulateDir / "Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala", defaultOpts, periodicMap)))

val rtsHome = home / "rts"
val actuationDir = rtsHome / "hamr" / "slang" / "src" / "main" / "component" / "RTS" / "Actuation"
val rts = "rts" ~>
  Project(rtsHome, "RTS", "RTS", ISZ(C(actuationDir / "Actuator_i_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator.scala", defaultOpts, periodicMap),
    C(actuationDir / "Actuator_i_actuationSubsystem_tempPressureActuatorUnit_tempPressureActuator_actuator.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_pressureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_saturationLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_temperatureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_pressureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_saturationLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_temperatureLogic_coincidenceLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "OrLogic_i_actuationSubsystem_actuationUnit1_tempPressureTripOut_orLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "OrLogic_i_actuationSubsystem_actuationUnit2_tempPressureTripOut_orLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "OrLogic_i_actuationSubsystem_saturationActuatorUnit_actuateSaturationActuator_orLogic.scala", defaultOpts, periodicMap),
    C(actuationDir / "OrLogic_i_actuationSubsystem_tempPressureActuatorUnit_actuateTempPressureActuator_orLogic.scala", defaultOpts, periodicMap)))

val tcPHome = home / "temp_control" / "periodic"
val tcPDir = tcPHome / "hamr" / "slang" / "src" / "main" / "component" / "tc"
val tcP = "tcPeriodic" ~>
  Project(tcPHome, "TempControl Periodic", "TempControl Periodic", ISZ[C](
    C(tcPDir / "TempControlSoftwareSystem" / "TempControlPeriodic_p_tcproc_tempControl.scala", defaultOpts, periodicMap),
    C(tcPDir / "TempSensor" / "TempSensorPeriodic_p_tcproc_tempSensor.scala", defaultOpts, periodicMap),
  ))

val tcSHome = home / "temp_control" / "sporadic"
val tcSDir = tcSHome / "hamr" / "slang" / "src" / "main" / "component" / "tc"
val tcS = "tcSporadic" ~>
  Project(tcSHome, "TempControl Sporadic", "TempControl Sporadic", ISZ[C](
    C(tcSDir / "TempControlSoftwareSystem" / "TempControl_s_tcproc_tempControl.scala", defaultOpts,
      sporadicMap + ("handle_fanAck" ~> emptyReport) + ("handle_setPoint" ~> emptyReport) + ("handle_tempChanged" ~> emptyReport)),
    C(tcSDir / "TempSensor" / "TempSensor_s_tcproc_tempSensor.scala", defaultOpts, periodicMap)))

val projects: Map[String, Project] = Map.empty + isolette + rts + tcP + tcS

val systemVersion = "System Version"
val compName = "Computer Name"
val modelId = "Model Identifier"
val processor = "Processor"
val memory = "Memory"

val sysInfo = getSystemInfo

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

Os.exit(result)

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