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
val sireum = sireumBin / (if(Os.isWin) "sireum.bat" else "sireum")

val htmlResultsDir: String = "public_html/dsc_results"

@datatype class Container(val project: String,
                          val packageName: String,
                          val objectName: String,

                          val prettyName: String,
                          val tag: String
                         ) {
  def dscPrefix: String = {
    return s"$project-$tag"
  }
}

@datatype class TContainer(val node: String,
                           val server: String,
                           val basePackage: String,
                           val projRoot: Os.Path,
                           val timeouts: ISZ[Z],
                           val containers: ISZ[Container])

val isolette = "isolette" ~> TContainer(
  "mac-mini-m1",
  "e2206hm02.cs.ksu.edu",
  "isolette",
  home / "isolette" / "hamr" / "slang",
  ISZ(1, 5, 30, 360),
  //ISZ(1, 5, 30),
  ISZ(
    Container("isolette", "isolette.Monitor", "Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm",
      "Manage Alarm", "ma"),
    Container("isolette", "isolette.Monitor", "Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface",
      "Manage Monitor Interface", "mmi"),
    Container("isolette", "isolette.Monitor", "Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode",
      "Manage Monitor Mode", "mmm"),

    Container("isolette", "isolette.Regulate", "Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source",
      "Manage Heat Source", "mhs"),
    Container("isolette", "isolette.Regulate", "Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source",
      "Manage Regulator Interface", "mri"),
    Container("isolette", "isolette.Regulate", "Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode",
      "Manage Regulator Mode", "mrm")
  )
)

val rts = "rts" ~> TContainer(
  "mac-mini-intel",
  "e2206hm03.cs.ksu.edu",
  "RTS",
  home / "rts" / "hamr" / "slang",
  ISZ(1, 5, 30, 360),
  ISZ(
    Container("rts", "RTS.Actuation", "Actuator_i_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator",
      "Saturation Actuator", "saturationActuator"),

    Container("rts", "RTS.Actuation", "Actuator_i_actuationSubsystem_tempPressureActuatorUnit_tempPressureActuator_actuator",
      "TempPressure Actuator Unit", "tempPressureActuator"),

    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_pressureLogic_coincidenceLogic",
      "Actuation Unit 1 Pressure Logic", "au1-pressureLogic"),
    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_saturationLogic_coincidenceLogic",
      "Actuation Unit 1 Saturation Logic", "au1-saturationLogic"),
    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit1_temperatureLogic_coincidenceLogic",
      "Actuation Unit 1 Temperature Logic", "au1-temperatureLogic"),


    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_pressureLogic_coincidenceLogic",
      "Actuation Unit 2 Pressure Logic", "au2-pressureLogic"),
    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_saturationLogic_coincidenceLogic",
      "Actuation Unit 2 Saturation Logic", "au2-saturationLogic"),
    Container("rts", "RTS.Actuation", "CoincidenceLogic_i_actuationSubsystem_actuationUnit2_temperatureLogic_coincidenceLogic",
      "Actuation Unit 2 Temperature Logic", "au2-temperatureLogic"),


    Container("rts", "RTS.Actuation", "OrLogic_i_actuationSubsystem_actuationUnit1_tempPressureTripOut_orLogic",
      "Actuation Unit 1 TempPressureTripOut or Logic", "au1-tempPressureTripOut"),
    Container("rts", "RTS.Actuation", "OrLogic_i_actuationSubsystem_actuationUnit2_tempPressureTripOut_orLogic",
      "Actuation Unit 2 TempPressureTripOut or Logic", "au2-tempPressureTripOut"),

    Container("rts", "RTS.Actuation", "OrLogic_i_actuationSubsystem_saturationActuatorUnit_actuateSaturationActuator_orLogic",
      "Actuate Saturation Actuator", "actuateSaturationActuator"),

    Container("rts", "RTS.Actuation", "OrLogic_i_actuationSubsystem_tempPressureActuatorUnit_actuateTempPressureActuator_orLogic",
      "Actuate TempPressure Actuator", "actuateTempPressureActuator")
  )
)

val tc = "tc" ~> TContainer(
  "mac-mini-m1",
  "e2206hm02.cs.ksu.edu",
  "tc",
  home / "temp_control" / "periodic" / "hamr" / "slang",
  ISZ(1, 5, 30, 360),
  ISZ(
    Container("tc", "tc.CoolingFan", "FanPeriodic_p_tcproc_fan",
      "Cooling Fan", "fan"),

    Container("tc", "tc.TempControlSoftwareSystem", "OperatorInterfacePeriodic_p_tcproc_operatorInterface",
      "Operator Interface", "operator-interface"),

    Container("tc", "tc.TempControlSoftwareSystem", "TempControlPeriodic_p_tcproc_tempControl",
      "Temperature Controller", "temp-control"),

    Container("tc", "tc.TempSensor", "TempSensorPeriodic_p_tcproc_tempSensor",
      "Temperature Sensor", "temp-sensor")
  )
)

val tc_f32_bw = "tc_f32_bw" ~> TContainer(
  "mac-mini-m1",
  "e2206hm02.cs.ksu.edu",
  "tc",
  home / "temp_control" / "periodic-f32-bw" / "hamr" / "slang",
  ISZ(1, 5, 30, 360),
  ISZ(
    Container("tc_f32_bw", "tc.CoolingFan", "FanPeriodic_p_tcproc_fan",
      "Cooling Fan", "fan"),

    Container("tc_f32_bw", "tc.TempControlSoftwareSystem", "OperatorInterfacePeriodic_p_tcproc_operatorInterface",
      "Operator Interface", "operator-interface"),

    Container("tc_f32_bw", "tc.TempControlSoftwareSystem", "TempControlPeriodic_p_tcproc_tempControl",
      "Temperature Controller", "temp-control"),

    Container("tc_f32_bw", "tc.TempSensor", "TempSensorPeriodic_p_tcproc_tempSensor",
      "Temperature Sensor", "temp-sensor")
  )
)

val projects: Map[String, TContainer] = Map.empty[String, TContainer] ++ ISZ(isolette, rts, tc, tc_f32_bw)


def getProj(): (String, TContainer) = {
  if (Os.cliArgs.size == 1) {
    println(s"Must specify a project: ${projects.keys}")
    Os.exit(0)
  }
  val proj: TContainer = projects.get(Os.cliArgs(1)) match {
    case Some(p) => p
    case x => halt(s"$x is not a valid project: ${projects.keys}")
  }
  return (Os.cliArgs(1), proj)
}

def getTimeout(tcontainer: TContainer): String = {
  if (Os.cliArgs.size != 3) {
    println(s"Must supply a timeout: ${tcontainer.timeouts}")
    Os.exit(0)
    halt("Infeasible")
  }
  else {
    val to = Os.cliArgs(2)
    if (!ops.ISZOps(tcontainer.timeouts).contains(Z(to).get)) {
      println(s"Must choose from: ${tcontainer.timeouts}")
      Os.exit(0)
      halt("Infeasible")
    }
    return to
  }
}

def test(): Unit = {

  val (project, tcontainer) = getProj()

  val timeout = getTimeout(tcontainer)

  val jar = tcontainer.projRoot / "out" / project / "assemble" / s"${project}.jar"
  val slangCheckLoc = tcontainer.projRoot / "src" / "main" / "data" / tcontainer.basePackage / "SlangCheckRandom.scala"

  val jobName = s"DSC_${project}_Begin"


  val jenkinsUser: String = Os.env("jenkins_user") match {
    case Some(u) => u
    case _ => halt("Must set jenkins_user environment variable")
  }

  val jenkinsToken: String = Os.env("jenkins_token") match {
    case Some(t) => t
    case _ => halt("Must set jenkins_token environment variable")
  }

  if (!jar.exists) {
    println("Replacing for loops with whiles ...")
    slangCheckLoc.writeOver(ops.StringOps(slangCheckLoc.read).replaceAllLiterally("for(i <- 0 to 100)", "while (true)"))

    println("Assembling ...")
    proc"sireum proyek assemble --include-sources --include-tests -n ${project} .".at(tcontainer.projRoot).console.runCheck()

    println("Reverting back to for loops ...")
    proc"git checkout ${slangCheckLoc.value}".at(tcontainer.projRoot).console.runCheck()
  }

  def upload(server: String): Unit = {
    println(s"Uploading ${jar} to $server ...")
    proc"ssh santos_jenkins@${server} mkdir -p dsc/${project}".console.runCheck()
    proc"scp ${jar.value} santos_jenkins@${server}:dsc/${project}/${jar.name}".console.runCheck()
  }

  upload("linux.cs.ksu.edu")
  upload("e2206hm02.cs.ksu.edu")
  upload("e2206hm03.cs.ksu.edu")


  for (c <- tcontainer.containers) {
    //val (runner_simple_name, timeout, runner_class_name) = l
    val runner_class_name = s"${c.packageName}.${c.objectName}_GumboX_SlangCheck_TestRunner"
    proc"curl  https://jenkins.cs.ksu.edu/job/${jobName}/buildWithParameters --user ${jenkinsUser}:${jenkinsToken} --data RUNNER_CLASS_NAME=${runner_class_name} --data RUNNER_SIMPLE_NAME=${c.dscPrefix} --data TIMEOUT=${timeout}".console.runCheck()
  }
}


def fetch(): Unit = {

  val (project, tcontainer) = getProj()

  val timeout = getTimeout(tcontainer)

  val timeoutDir = s"/opt/santos/jenkins/dsc-jacoco/${project}/timeout_${timeout}"
  val zipPrefix = s"${project}_timeout_${timeout}"

  for (c <- tcontainer.containers) {
    val dscPrefix = s"${timeoutDir}/${c.dscPrefix}-${tcontainer.node}-dsc-tested"
    def ffetch(ext: String): Z = {
      val temp = Os.temp()
      proc"scp santos_jenkins@${tcontainer.server}:${dscPrefix}.${ext} ${temp.value}".console.runCheck()
      return temp.readLines.size
    }
    val passing = ffetch("passing")
    val failing = ffetch("failing")
    val unsat = ffetch("unsat")
    val ttemp = Os.temp()
    ttemp.writeOver(s"${passing-unsat}\n${failing}\n${unsat}\n")
    proc"scp ${ttemp.value} santos_jenkins@${tcontainer.server}:${dscPrefix}.results".console.runCheck()
  }

  val cmd = s"\"cd $timeoutDir && zip -r ${zipPrefix}.zip . -x '*dump*'\""
  proc"ssh santos_jenkins@${tcontainer.server} sh -c $cmd".echo.console.runCheck()
  println()
  println(s"Downloading via: scp santos_jenkins@${tcontainer.server}:${timeoutDir}/${zipPrefix}.zip ${zipPrefix}.zip")

  val resultsDir = s"${htmlResultsDir}/${project}/results"
  proc"ssh santos_jenkins@linux.cs.ksu.edu rm -rf ${resultsDir}/${zipPrefix}".console.runCheck()
  proc"ssh santos_jenkins@linux.cs.ksu.edu mkdir -p ${resultsDir}".console.runCheck()
  proc"scp santos_jenkins@${tcontainer.server}:${timeoutDir}/${zipPrefix}.zip santos_jenkins@linux.cs.ksu.edu:${resultsDir}/${zipPrefix}.zip".echo.console.runCheck()
  proc"ssh santos_jenkins@linux.cs.ksu.edu unzip ${resultsDir}/${zipPrefix}.zip -d ${resultsDir}/${zipPrefix}".console.runCheck()
}

def report(): Unit = {
  for (e <- projects.entries) {
    println(s"Generating report for ${e._1}")
    var components: ISZ[ST] = ISZ()
    for (p <- e._2.containers) {
      var rows: ISZ[ST] = ISZ()
      for (t <- e._2.timeouts) {
        val timeoutPrefix = s"${p.project}_timeout_${t}"

        val directoryPrefix = s"results/${timeoutPrefix}/"

        val prefix = s"${p.dscPrefix}-${e._2.node}"

        val jPrefix = s"${prefix}-jacoco.coverage"

        val tr = Os.temp()
        val dscResults = s"${p.project}/${directoryPrefix}/${prefix}-dsc-tested.results"
        proc"scp santos_jenkins@linux.cs.ksu.edu:${htmlResultsDir}/$dscResults ${tr.value}".console.runCheck()
        val trl = tr.readLines
        val passing = Z(trl(0)).get
        val failing = Z(trl(1)).get
        val unsat = Z(trl(2)).get
        val total = passing + failing + unsat

        val passingLink = s"${directoryPrefix}/${prefix}-dsc-tested.passing"
        val failingLink = s"${directoryPrefix}/${prefix}-dsc-tested.failing"
        val unsatLink = s"${directoryPrefix}/${prefix}-dsc-tested.unsat"

        val csv = s"${directoryPrefix}/${jPrefix}.csv"
        val metrics = s"${directoryPrefix}/${jPrefix}/${p.packageName}/index.source.html"
        val ccov = s"${directoryPrefix}/${jPrefix}/${p.packageName}/${p.objectName}.scala.html"
        val gcov = s"${directoryPrefix}/${jPrefix}/${p.packageName}/${p.objectName}_GumboX.scala.html"

        rows = rows :+
          st"""<tr>
              |  <td>${t}</td>
              |  <td>$total</td>
              |  <td><a href="$passingLink">$passing</a></td>
              |  <td><a href="$failingLink">$failing</a></td>
              |  <td><a href="$unsatLink">$unsat</a></td>
              |  <td><a href="$metrics">link</a></td>
              |  <td><a href="$ccov">link</a></td>
              |  <td><a href="$gcov">link</a></td>
              |  <td><a href="$csv">csv</a></td>
              |  <td><a href="results/${timeoutPrefix}.zip">zip</a></td>
              |</tr>"""
      }

      components = components :+
        st"""<h2>${p.prettyName}</h2>
            |<table border=1>
            |  <tr>
            |    <th>Timeout (s)</th>
            |    <th>Total<br>Tests</th>
            |    <th>Passing<br>Tests</th>
            |    <th>Failing<br>Tests</th>
            |    <th>Unsat<br>Requires</th>
            |    <th>Package<br>Coverage</th>
            |    <th>Component<br>Coverage</th>
            |    <th>GumboX<br>Coverage</th>
            |    <th>csv<br>Coverage</th>
            |    <th>Zipped<br>Results</th>
            |  </tr>
            |  ${(rows, "\n")}
            |</table>"""
    }

    val projWebsite =
      st"""<html>
          |  <style>
          |    a { text-decoration: none; }
          |    table {
          |      border: collapse;
          |      table-layout: fixed;
          |    }
          |    th {
          |      background-color: #E5E4E2;
          |      padding-left: 5px;
          |      padding-right: 5px;
          |    }
          |    td {
          |      padding-left: 5px;
          |      padding-right: 5px;
          |    }
          |    tr:nth-child(odd) { background-color: #f2f2f2; }
          |  </style>
          |  <body>
          |     ${(components, "\n")}
          |  </body>
          |</html>"""

    val f = Os.temp()
    f.writeOver(projWebsite.render)

    proc"scp ${f.value} santos_jenkins@linux.cs.ksu.edu:${htmlResultsDir}/${e._1}/${e._1}.html".console.runCheck()
  }

  val website =
    st"""<html>
        |  <body>
        |    ${(for (k <- projects.keys) yield s"<a href=\"${k}/${k}.html\">${k}</a>", "\n\n<p>")}
        |  </body>
        |</html>"""

  val f = Os.temp()
  f.writeOver(website.render)

  proc"scp ${f.value} santos_jenkins@linux.cs.ksu.edu:${htmlResultsDir}/index.html".console.runCheck()
}

if (Os.cliArgs.isEmpty) {
  println("Choose an option (test | fetch | report)")
  Os.exit(0)
}

Os.cliArgs(0) match {
  case string"test" => test()
  case string"fetch" => fetch()
  case string"report" => report()
  case _ => halt("Not a valid option")
}