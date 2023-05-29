# Isolette

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
|Threads|11|
|Ports|49|
|Connections|27|

### JVM Metrics
Directories Scanned Using [https://github.com/AlDanial/cloc](https://github.com/AlDanial/cloc) v1.94:
- [hamr/slang/src/main](hamr/slang/src/main)

<u><b>Total LOC</b></u>

Total number of HAMR-generated and developer-written lines of code
Language|files|blank|comment|code
:-------|-------:|-------:|-------:|-------:
Scala|87|2936|2160|10796
--------|--------|--------|--------|--------
SUM:|87|2936|2160|10796

<u><b>User LOC</b></u>

The number of lines of code written by the developer.
"Log" are lines of code used for logging that
likely would be excluded in a release build
 |Type|code |
 |--|--:|
 |Behavior|184|
 |Log|16|
 |--------|--------|
 |SUM:|200|

### DSC Coverage
[https://people.cs.ksu.edu/~santos_jenkins/dsc_results/isolette/isolette.html](https://people.cs.ksu.edu/~santos_jenkins/dsc_results/isolette/isolette.html)

## Run Instructions
*NOTE:* actual output may differ due to issues related to thread interleaving
### JVM

  |HAMR Codegen Configuration| |
  |--|--|
  | package-name | isolette |
  | exclude-component-impl | false |
  | bit-width | 32 |
  | max-string-size | 256 |
  | max-array-size | 1 |


  **How To Run**
  ```
  sireum proyek run isolette/hamr/slang isolette.Demo
  ```
