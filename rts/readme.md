# RTS

 Table of Contents
  * [Diagrams](#diagrams)
    * [AADL Arch](#aadl-arch)
  * [Metrics](#metrics)
    * [AADL Metrics](#aadl-metrics)
    * [JVM Metrics](#jvm-metrics)
  * [Run Instructions](#run-instructions)
    * [JVM](#jvm)

## Diagrams
### AADL Arch
![AADL Arch](aadl/diagrams/aadl-arch.svg)

## Metrics
### AADL Metrics
| | |
|--|--|
|Threads|15|
|Ports|76|
|Connections|38|

### JVM Metrics
Directories Scanned Using [https://github.com/AlDanial/cloc](https://github.com/AlDanial/cloc) v1.94:
- [hamr/slang/src/main](hamr/slang/src/main)

<u><b>Total LOC</b></u>

Total number of HAMR-generated and developer-written lines of code
Language|files|blank|comment|code
:-------|-------:|-------:|-------:|-------:
Scala|91|2421|1832|9003
--------|--------|--------|--------|--------
SUM:|91|2421|1832|9003

<u><b>User LOC</b></u>

The number of lines of code written by the developer.
"Log" are lines of code used for logging that
likely would be excluded in a release build
 |Type|code |
 |--|--:|
 |Behavior|156|
 |Log|6|
 |--------|--------|
 |SUM:|162|

 ### DSC Coverage
 [https://people.cs.ksu.edu/~santos_jenkins/dsc_results/rts/rts.html](https://people.cs.ksu.edu/~santos_jenkins/dsc_results/rts/rts.html)

## Run Instructions
*NOTE:* actual output may differ due to issues related to thread interleaving
### JVM

  |HAMR Codegen Configuration| |
  |--|--|
  | package-name | RTS |
  | exclude-component-impl | false |
  | bit-width | 32 |
  | max-string-size | 256 |
  | max-array-size | 1 |


  **How To Run**
  ```
  sireum proyek run rts/hamr/slang RTS.Demo
  ```
