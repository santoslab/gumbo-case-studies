# <!---title_start-->Temperature Control Sporadic<!---title_end-->
<!---description_start-->
<!---description_end-->
## <!--arch-section-title_start-->AADL Architecture<!--arch-section-title_end-->
<!--arch-section-description_start-->
<!--arch-section-description_end-->
<!--arch-section-aadl-arch-diagram_start-->
![AADL Arch](aadl/diagrams/aadl-arch.svg)
<!--arch-section-aadl-arch-diagram_end-->
<!--arch-section-aadl-arch-component-info-TempControlSoftwareSystem_s_Instance_start-->
|System: [TempControlSoftwareSystem_s_Instance](aadl/packages/TempControlSoftwareSystem.aadl#L61) |
|--|
<!--arch-section-aadl-arch-component-info-TempControlSoftwareSystem_s_Instance_end-->
<!--arch-section-aadl-arch-component-info-fan_start-->
|Thread: [fan](aadl/packages/TempControlSoftwareSystem.aadl#L85) |
|--|
|Classifier: [CoolingFan::Fan.s](aadl/packages/CoolingFan.aadl#L58)|
|Sporadic|

<!--arch-section-aadl-arch-component-info-fan_end-->
<!--arch-section-aadl-arch-component-info-operatorInterface_start-->
|Thread: [operatorInterface](aadl/packages/TempControlSoftwareSystem.aadl#L87) |
|--|
|Classifier: [TempControlSoftwareSystem::OperatorInterface.s](aadl/packages/TempControlSoftwareSystem.aadl#L288)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-operatorInterface_end-->
<!--arch-section-aadl-arch-component-info-tempControl_start-->
|Thread: [tempControl](aadl/packages/TempControlSoftwareSystem.aadl#L86) |
|--|
|Classifier: [TempControlSoftwareSystem::TempControl.s](aadl/packages/TempControlSoftwareSystem.aadl#L247)|
|Sporadic|

<!--arch-section-aadl-arch-component-info-tempControl_end-->
<!--arch-section-aadl-arch-component-info-tempSensor_start-->
|Thread: [tempSensor](aadl/packages/TempControlSoftwareSystem.aadl#L84) |
|--|
|Classifier: [TempSensor::TempSensor.s](aadl/packages/TempSensor.aadl#L78)|
|Periodic: 1000 ms|

<!--arch-section-aadl-arch-component-info-tempSensor_end-->

## <!--logika-title_start-->Logika<!--logika-title_end-->
<!--logika-description_start-->
<script type="text/javascript"
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_CHTML">
</script>
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [['$','$'], ['\\(','\\)']],
      processEscapes: true},
      jax: ["input/TeX","input/MathML","input/AsciiMath","output/CommonHTML"],
      extensions: ["tex2jax.js","mml2jax.js","asciimath2jax.js","MathMenu.js","MathZoom.js","AssistiveMML.js", "[Contrib]/a11y/accessibility-menu.js"],
      TeX: {
      extensions: ["AMSmath.js","AMSsymbols.js","noErrors.js","noUndefined.js"],
      equationNumbers: {
      autoNumber: "AMS"
      }
    }
  });
</script>
The following reports the experimental data obtained by running Logika
only on the component entrypoints that require verification (e.g. TempControl's
Fan component was excluded as it does not contain GUMBO contracts and does not
use datatypes that have invariants).  Logika was configured with a 2 second
validity checking timeout, a 500 millisecond satisfiability checking timeout, a
SMT2 resource limit of 2,000,000, and with full parallelization optimizations
enabled.  The SMT2 solvers used include CVC4 1.8, CVC5 1.0.5, and Z3 4.12.2. The
${\bf VC}$ and ${\bf SAT}$ columns report the number of verification and
satisfiability conditions that were checked, respectively.  The time values
reported in the final three columns are the averages obtained after re-running
Logika 25 times for each entrypoint on an M1 Mac Mini with 8 cores and 16 GB of
RAM.  ${\bf TTime}$ gives the total number of seconds it took to run Logika
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
column (${\bf ITCTime}$).  The time required to actually verify an entrypoint with
a clean cache is reported in the Verification-Time column (${\bf VTime}$) so
incremental type checking for this example would save 2.268 seconds (2.482 -
0.214) on average.
<!--logika-description_end-->
### <!--logiak-results-title_start-->Results<!--logiak-results-title_end-->
<!--logiak-results-description_start-->
<!--logiak-results-description_end-->
<!--logiak-results-logika-TempSensor_s_tcproc_tempSensor_start-->

**tempSensor**

Raw Data: [csv](hamr/slang/src/main/component/tc/TempSensor/.TempSensor_s_tcproc_tempSensor.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/tc/TempSensor/TempSensor_s_tcproc_tempSensor.scala#L15)|3|2|2.969|0.104|0.784|
|[timeTriggered](hamr/slang/src/main/component/tc/TempSensor/TempSensor_s_tcproc_tempSensor.scala#L37)|1|2|2.808|0.103|0.636|
<!--logiak-results-logika-TempSensor_s_tcproc_tempSensor_end-->
<!--logiak-results-logika-TempControl_s_tcproc_tempControl_start-->

**tempControl**

Raw Data: [csv](hamr/slang/src/main/component/tc/TempControlSoftwareSystem/.TempControl_s_tcproc_tempControl.scala.csv)

EntryPoint|VC|SAT|TTime|ITCTime|VTime|
|--|--|--|--|--|--|
|[initialise](hamr/slang/src/main/component/tc/TempControlSoftwareSystem/TempControl_s_tcproc_tempControl.scala#L21)|9|2|3.349|0.102|1.198|
|[handle_fanAck](hamr/slang/src/main/component/tc/TempControlSoftwareSystem/TempControl_s_tcproc_tempControl.scala#L59)|11|8|5.347|0.103|3.164|
|[handle_setPoint](hamr/slang/src/main/component/tc/TempControlSoftwareSystem/TempControl_s_tcproc_tempControl.scala#L131)|9|10|7.060|0.107|4.878|
|[handle_tempChanged](hamr/slang/src/main/component/tc/TempControlSoftwareSystem/TempControl_s_tcproc_tempControl.scala#L194)|11|10|8.509|0.105|6.315|
<!--logiak-results-logika-TempControl_s_tcproc_tempControl_end-->

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
on each entrypoint: [../../bin/report-logika.cmd](../../bin/report-logika.cmd)

```
../../bin/report-logika.cmd run 25
```

The results will be appended to the csv file corresponding to the component
being evaluated. The line ``val projects: Map[String, Project] = Map.empty + isolette + rts + tcP + tcS``
in the script can be modified if you want to run a subset of the projects
<!--how-to-run-description_end-->
