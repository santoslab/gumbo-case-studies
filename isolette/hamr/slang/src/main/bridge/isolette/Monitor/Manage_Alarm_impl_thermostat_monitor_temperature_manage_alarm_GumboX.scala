// #Sireum

package isolette.Monitor

import org.sireum._
import isolette._

// This file was auto-generated.  Do not edit
object Manage_Alarm_impl_thermostat_monitor_temperature_manage_alarm_GumboX {
  /** Initialize Entrypoint Contract
    *
    * guarantees REQ_MA_1
    *   If the Monitor Mode is INIT, the Alarm Control shall be set
    *   to Off.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param lastCmd post-state state variable
    * @param api_alarm_control outgoing data port
    */
  @strictpure def initialize_REQ_MA_1 (
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    api_alarm_control == Isolette_Data_Model.On_Off.Off &
      lastCmd == Isolette_Data_Model.On_Off.Off

  /** IEP-Guar: Initialize Entrypoint Contracts for manage_alarm
    *
    * @param lastCmd post-state state variable
    * @param api_alarm_control outgoing data port
    */
  @strictpure def initialize_IEP_Guar (
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    initialize_REQ_MA_1(lastCmd, api_alarm_control)

  /** IEP-Post: Initialize Entrypoint Post-Condition
    *
    * @param lastCmd post-state state variable
    * @param api_alarm_control outgoing data port
    */
  @strictpure def inititialize_IEP_Post (
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (// IEP-Guar: Initialize Entrypoint contract for manage_alarm
     initialize_IEP_Guar(lastCmd, api_alarm_control))

  /** Compute Entrypoint Contract
    *
    * assumes Figure_A_7
    *   This is not explicitly stated in the requirements, but a reasonable
    *   assumption is that the lower alarm must be at least 1.0f less than
    *   the upper alarm in order to account for the 0.5f tolerance
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param api_lower_alarm_temp incoming data port
    * @param api_upper_alarm_temp incoming data port
    */
  @strictpure def compute_spec_Figure_A_7_assume(
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl): B =
    api_upper_alarm_temp.value - api_lower_alarm_temp.value >= 1.0f

  /** Compute Entrypoint Contract
    *
    * assumes Table_A_12_LowerAlarmTemp
    *   Range [96..101]
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=112 
    * @param api_lower_alarm_temp incoming data port
    */
  @strictpure def compute_spec_Table_A_12_LowerAlarmTemp_assume(
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl): B =
    96.0f <= api_lower_alarm_temp.value &&
      api_lower_alarm_temp.value <= 101.0f

  /** Compute Entrypoint Contract
    *
    * assumes Table_A_12_UpperAlarmTemp
    *   Range [97..102]
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=112 
    * @param api_upper_alarm_temp incoming data port
    */
  @strictpure def compute_spec_Table_A_12_UpperAlarmTemp_assume(
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl): B =
    97.0f <= api_upper_alarm_temp.value &&
      api_upper_alarm_temp.value <= 102.0f

  /** CEP-T-Assm: Top-level assume contracts for manage_alarm's compute entrypoint
    *
    * @param api_lower_alarm_temp incoming data port
    * @param api_upper_alarm_temp incoming data port
    */
  @strictpure def compute_CEP_T_Assm (
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl): B =
    compute_spec_Figure_A_7_assume(api_lower_alarm_temp, api_upper_alarm_temp) &
    compute_spec_Table_A_12_LowerAlarmTemp_assume(api_lower_alarm_temp) &
    compute_spec_Table_A_12_UpperAlarmTemp_assume(api_upper_alarm_temp)

  /** CEP-Pre: Compute Entrypoint Pre-Condition for manage_alarm
    *
    * @param In_lastCmd pre-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    */
  @strictpure def compute_CEP_Pre (
      In_lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl): B =
    (// CEP-Assm: assume clauses of manage_alarm's compute entrypoint
     compute_CEP_T_Assm (api_lower_alarm_temp, api_upper_alarm_temp))

  /** guarantees REQ_MA_1
    *   If the Monitor Mode is INIT, the Alarm Control shall be set
    *   to Off.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param lastCmd post-state state variable
    * @param api_monitor_mode incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_case_REQ_MA_1(
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (api_monitor_mode == Isolette_Data_Model.Monitor_Mode.Init_Monitor_Mode) -->:
      (api_alarm_control == Isolette_Data_Model.On_Off.Off &
         lastCmd == Isolette_Data_Model.On_Off.Off)

  /** guarantees REQ_MA_2
    *   If the Monitor Mode is NORMAL and the Current Temperature is
    *   less than the Lower Alarm Temperature or greater than the Upper Alarm
    *   Temperature, the Alarm Control shall be set to On.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param lastCmd post-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_case_REQ_MA_2(
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (api_monitor_mode == Isolette_Data_Model.Monitor_Mode.Normal_Monitor_Mode &
       (api_current_tempWstatus.value < api_lower_alarm_temp.value ||
         api_current_tempWstatus.value > api_upper_alarm_temp.value)) -->:
      (api_alarm_control == Isolette_Data_Model.On_Off.Onn &
         lastCmd == Isolette_Data_Model.On_Off.Onn)

  /** guarantees REQ_MA_3
    *   If the Monitor Mode is NORMAL and the Current Temperature
    *   is greater than or equal to the Lower Alarm Temperature and less than
    *   the Lower Alarm Temperature +0.5 degrees, or the Current Temperature is
    *   greater than the Upper Alarm Temperature -0.5 degrees and less than or equal
    *   to the Upper Alarm Temperature, the value of the Alarm Control shall
    *   not be changed.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param In_lastCmd pre-state state variable
    * @param lastCmd post-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_case_REQ_MA_3(
      In_lastCmd: Isolette_Data_Model.On_Off.Type,
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (api_monitor_mode == Isolette_Data_Model.Monitor_Mode.Normal_Monitor_Mode &
       (api_current_tempWstatus.value >= api_lower_alarm_temp.value &&
         api_current_tempWstatus.value < api_lower_alarm_temp.value + 0.5f ||
         api_current_tempWstatus.value > api_upper_alarm_temp.value - 0.5f &&
           api_current_tempWstatus.value <= api_upper_alarm_temp.value)) -->:
      (api_alarm_control == In_lastCmd &
         lastCmd == In_lastCmd)

  /** guarantees REQ_MA_4
    *   If the Monitor Mode is NORMAL and the value of the Current
    *   Temperature is greater than or equal to the Lower Alarm Temperature
    *   +0.5 degrees and less than or equal to the Upper Alarm Temperature
    *   -0.5 degrees, the Alarm Control shall be set to Off.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=115 
    * @param lastCmd post-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_case_REQ_MA_4(
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (api_monitor_mode == Isolette_Data_Model.Monitor_Mode.Normal_Monitor_Mode &
       api_current_tempWstatus.value >= api_lower_alarm_temp.value + 0.5f &
       api_current_tempWstatus.value <= api_upper_alarm_temp.value - 0.5f) -->:
      (api_alarm_control == Isolette_Data_Model.On_Off.Off &
         lastCmd == Isolette_Data_Model.On_Off.Off)

  /** guarantees REQ_MA_5
    *   If the Monitor Mode is FAILED, the Alarm Control shall be
    *   set to On.
    *   http://pub.santoslab.org/high-assurance/module-requirements/reading/FAA-DoT-Requirements-AR-08-32.pdf#page=116 
    * @param lastCmd post-state state variable
    * @param api_monitor_mode incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_case_REQ_MA_5(
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (api_monitor_mode == Isolette_Data_Model.Monitor_Mode.Failed_Monitor_Mode) -->:
      (api_alarm_control == Isolette_Data_Model.On_Off.Onn &
         lastCmd == Isolette_Data_Model.On_Off.Onn)

  /** CEP-T-Case: Top-Level case contracts for manage_alarm's compute entrypoint
    *
    * @param In_lastCmd pre-state state variable
    * @param lastCmd post-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_CEP_T_Case (
      In_lastCmd: Isolette_Data_Model.On_Off.Type,
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    compute_case_REQ_MA_1(lastCmd, api_monitor_mode, api_alarm_control) &
    compute_case_REQ_MA_2(lastCmd, api_current_tempWstatus, api_lower_alarm_temp, api_monitor_mode, api_upper_alarm_temp, api_alarm_control) &
    compute_case_REQ_MA_3(In_lastCmd, lastCmd, api_current_tempWstatus, api_lower_alarm_temp, api_monitor_mode, api_upper_alarm_temp, api_alarm_control) &
    compute_case_REQ_MA_4(lastCmd, api_current_tempWstatus, api_lower_alarm_temp, api_monitor_mode, api_upper_alarm_temp, api_alarm_control) &
    compute_case_REQ_MA_5(lastCmd, api_monitor_mode, api_alarm_control)

  /** CEP-Post: Compute Entrypoint Post-Condition for manage_alarm
    *
    * @param In_lastCmd pre-state state variable
    * @param lastCmd post-state state variable
    * @param api_current_tempWstatus incoming data port
    * @param api_lower_alarm_temp incoming data port
    * @param api_monitor_mode incoming data port
    * @param api_upper_alarm_temp incoming data port
    * @param api_alarm_control outgoing data port
    */
  @strictpure def compute_CEP_Post (
      In_lastCmd: Isolette_Data_Model.On_Off.Type,
      lastCmd: Isolette_Data_Model.On_Off.Type,
      api_current_tempWstatus: Isolette_Data_Model.TempWstatus_impl,
      api_lower_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_monitor_mode: Isolette_Data_Model.Monitor_Mode.Type,
      api_upper_alarm_temp: Isolette_Data_Model.Temp_impl,
      api_alarm_control: Isolette_Data_Model.On_Off.Type): B =
    (// CEP-T-Case: case clauses of manage_alarm's compute entrypoint
     compute_CEP_T_Case (In_lastCmd, lastCmd, api_current_tempWstatus, api_lower_alarm_temp, api_monitor_mode, api_upper_alarm_temp, api_alarm_control))
}
