# <!---title_start-->Isolette<!---title_end-->
<!---description_start-->
<!---description_end-->
## <!--arch-section-title_start-->AADL Architecture<!--arch-section-title_end-->
<!--arch-section-description_start-->
<!--arch-section-description_end-->
<!--arch-section-aadl-arch-diagram_start-->
![AADL Arch](aadl/diagrams/aadl-arch.svg)
<!--arch-section-aadl-arch-diagram_end-->
<!--arch-section-aadl-arch-component-info-isolette_single_sensor_Instance_start-->
|System: [isolette_single_sensor_Instance](aadl/aadl/packages/Isolette.aadl#L71) |
|--|
<!--arch-section-aadl-arch-component-info-isolette_single_sensor_Instance_end-->
<!--arch-section-aadl-arch-component-info-heat_controller_start-->
|Thread: [heat_controller](aadl/aadl/packages/Devices.aadl#L118) |
|--|
|Classifier: [Devices::Heat_Source.impl](aadl/aadl/packages/Devices.aadl#L135)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-heat_controller_end-->
<!--arch-section-aadl-arch-component-info-thermostat_start-->
|Thread: [thermostat](aadl/aadl/packages/Devices.aadl#L73) |
|--|
|Classifier: [Devices::Temperature_Sensor.impl](aadl/aadl/packages/Devices.aadl#L90)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-thermostat_end-->
<!--arch-section-aadl-arch-component-info-oit_start-->
|Thread: [oit](aadl/aadl/packages/Isolette.aadl#L274) |
|--|
|Classifier: [Isolette::operator_interface_thread.impl](aadl/aadl/packages/Isolette.aadl#L307)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-oit_end-->
<!--arch-section-aadl-arch-component-info-detect_monitor_failure_start-->
|Thread: [detect_monitor_failure](aadl/aadl/packages/Monitor.aadl#L43) |
|--|
|Classifier: [Monitor::Detect_Monitor_Failure.impl](aadl/aadl/packages/Monitor.aadl#L439)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-detect_monitor_failure_end-->
<!--arch-section-aadl-arch-component-info-manage_alarm_start-->
|Thread: [manage_alarm](aadl/aadl/packages/Monitor.aadl#L39) |
|--|
|Classifier: [Monitor::Manage_Alarm.impl](aadl/aadl/packages/Monitor.aadl#L321)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_alarm_end-->
<!--arch-section-aadl-arch-component-info-manage_monitor_interface_start-->
|Thread: [manage_monitor_interface](aadl/aadl/packages/Monitor.aadl#L37) |
|--|
|Classifier: [Monitor::Manage_Monitor_Interface.impl](aadl/aadl/packages/Monitor.aadl#L125)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_monitor_interface_end-->
<!--arch-section-aadl-arch-component-info-manage_monitor_mode_start-->
|Thread: [manage_monitor_mode](aadl/aadl/packages/Monitor.aadl#L41) |
|--|
|Classifier: [Monitor::Manage_Monitor_Mode.impl](aadl/aadl/packages/Monitor.aadl#L240)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_monitor_mode_end-->
<!--arch-section-aadl-arch-component-info-detect_regulator_failure_start-->
|Thread: [detect_regulator_failure](aadl/aadl/packages/Regulate.aadl#L48) |
|--|
|Classifier: [Regulate::Detect_Regulator_Failure.impl](aadl/aadl/packages/Regulate.aadl#L518)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-detect_regulator_failure_end-->
<!--arch-section-aadl-arch-component-info-manage_heat_source_start-->
|Thread: [manage_heat_source](aadl/aadl/packages/Regulate.aadl#L42) |
|--|
|Classifier: [Regulate::Manage_Heat_Source.impl](aadl/aadl/packages/Regulate.aadl#L489)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_heat_source_end-->
<!--arch-section-aadl-arch-component-info-manage_regulator_interface_start-->
|Thread: [manage_regulator_interface](aadl/aadl/packages/Regulate.aadl#L38) |
|--|
|Classifier: [Regulate::Manage_Regulator_Interface.impl](aadl/aadl/packages/Regulate.aadl#L256)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_regulator_interface_end-->
<!--arch-section-aadl-arch-component-info-manage_regulator_mode_start-->
|Thread: [manage_regulator_mode](aadl/aadl/packages/Regulate.aadl#L46) |
|--|
|Classifier: [Regulate::Manage_Regulator_Mode.impl](aadl/aadl/packages/Regulate.aadl#L383)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-manage_regulator_mode_end-->

## <!--logika-title_start-->Logika<!--logika-title_end-->
<!--logika-description_start-->
The following reports the experimental data obtained by running Logika
only on the component entrypoints that require verification (e.g. TempControl's
Fan component was excluded as it does not contain GUMBO contracts and does not
use datatypes that have invariants).  Logika was configured with a 2 second
validity checking timeout, a 500 millisecond satisfiability checking timeout, a
SMT2 resource limit of 2,000,000, and with full parallelization optimizations
enabled.  The SMT2 solvers used include CVC4 1.8, CVC5 1.0.5, and Z3 4.12.2. The
**VC** and **SAT** columns report the number of verification and
satisfiability conditions that were checked, respectively.  The time values
reported in the final three columns are the averages obtained after re-running
Logika 25 times for each entrypoint on an M1 Mac Mini with 8 cores and 16 GB of
RAM.  **TTime** gives the total number of seconds it took to run Logika
from the command line on the Slang project containing the entrypoint (i.e. it
includes the verification time along with the time required for parsing, type
checking, etc.).

One optimization technique related to using Logika from within IVE that can be
measured via our experimental setup is Sireum's incremental type checking. For
example, if Logika was run on the Isolette MA component's initialize entrypoint
from within IVE using an identical configuration as was done for the experiments
then it will take on average 2.482 seconds to verify, assuming Logika had not
previously been invoked.  If a change was then made to MA's source code before
re-running Logika on the timeTriggered entrypoint then Sireum's incremental type
checking will only need to recheck MA (and any of its dependents) resulting in
an average delay of only 0.214 seconds before verification can proceed. The
results of these optimizations are reported in the Incremental-Type Checking
column (**ITCTime**).  The time required to actually verify an entrypoint with
a clean cache is reported in the Verification-Time column (**VTime**) so
incremental type checking for this example would save 2.268 seconds (2.482 -
0.214) on average.
<!--logika-description_end-->
### <!--logiak-results-title_start-->Results<!--logiak-results-title_end-->
<!--logiak-results-description_start-->
<!--logiak-results-description_end-->
<!--logiak-results-logika-Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface_start-->

**manage_regulator_interface**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Regulate/.Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Regulate/Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala#L15)|1|0|2.347|0.177|0.082|
|[timeTriggered](hamr/slang/src/main/component/isolette/Regulate/Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface.scala#L38)|13|32|16.632|0.172|14.394|
<!--logiak-results-logika-Manage_Regulator_Interface_impl_thermostat_regulate_temperature_manage_regulator_interface_end-->
<!--logiak-results-logika-Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source_start-->

**manage_heat_source**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Regulate/.Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Regulate/Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala#L20)|2|0|2.331|0.177|0.074|
|[timeTriggered](hamr/slang/src/main/component/isolette/Regulate/Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source.scala#L47)|10|17|10.051|0.174|7.796|
<!--logiak-results-logika-Manage_Heat_Source_impl_thermostat_regulate_temperature_manage_heat_source_end-->
<!--logiak-results-logika-Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode_start-->

**manage_regulator_mode**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Regulate/.Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Regulate/Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala#L18)|1|0|2.420|0.177|0.037|
|[timeTriggered](hamr/slang/src/main/component/isolette/Regulate/Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode.scala#L40)|8|56|28.320|0.173|26.100|
<!--logiak-results-logika-Manage_Regulator_Mode_impl_thermostat_regulate_temperature_manage_regulator_mode_end-->
<!--logiak-results-logika-Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface_start-->

**manage_monitor_interface**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Monitor/.Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Monitor/Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala#L19)|1|0|2.508|0.182|0.070|
|[timeTriggered](hamr/slang/src/main/component/isolette/Monitor/Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface.scala#L39)|10|28|16.641|0.180|14.404|
<!--logiak-results-logika-Manage_Monitor_Interface_impl_thermostat_monitor_temperature_manage_monitor_interface_end-->
<!--logiak-results-logika-Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm_start-->

**manage_alarm**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Monitor/.Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Monitor/Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala#L19)|1|0|2.468|0.204|0.053|
|[timeTriggered](hamr/slang/src/main/component/isolette/Monitor/Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm.scala#L44)|9|29|16.335|0.195|14.050|
<!--logiak-results-logika-Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm_end-->
<!--logiak-results-logika-Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode_start-->

**manage_monitor_mode**

Raw Data: [csv](hamr/slang/src/main/component/isolette/Monitor/.Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/isolette/Monitor/Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala#L19)|1|0|2.294|0.177|0.037|
|[timeTriggered](hamr/slang/src/main/component/isolette/Monitor/Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode.scala#L37)|7|31|16.095|0.178|13.852|
<!--logiak-results-logika-Manage_Monitor_Mode_impl_thermostat_monitor_temperature_manage_monitor_mode_end-->

### <!--how-to-run-title_start-->How to replicate<!--how-to-run-title_end-->
<!--how-to-run-description_start-->
To run the experiments, first install Sireum Kekinian (optionally choosing the
commit tip used for the experiments, ie. [843ede1](https://github.com/sireum/kekinian/tree/843ede1120e6e75fde089db0928ab66a3c9a3e73))

```
git clone --rec https://github.com/sireum/kekinian.git
cd kekinian
git checkout 843ede1
git pull --rec
bin/build.cmd

export SIREUM_HOME=$(pwd)
export PATH=$SIREUM_HOME/bin:$PATH
```

Then run the following Slash script specifying the number of number of times to rerun Logika
on each entrypoint: [../bin/report-logika.cmd](../bin/report-logika.cmd)

```
../bin/report-logika.cmd run 25
```

The results will be appended to the csv file corresponding to the component
being evaluated. The line ``val projects: Map[String, Project] = Map.empty + isolette + rts + tcP + tcS``
in the script can be modified if you want to run a subset of the projects
<!--how-to-run-description_end-->
