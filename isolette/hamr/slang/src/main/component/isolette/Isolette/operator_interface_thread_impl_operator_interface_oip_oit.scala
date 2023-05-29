// #Sireum

package isolette.Isolette

import org.sireum._
import isolette._

// This file will not be overwritten so is safe to edit
object operator_interface_thread_impl_operator_interface_oip_oit {

  def initialise(api: operator_interface_thread_impl_Initialization_Api): Unit = {
    api.put_lower_desired_tempWstatus(Isolette_Data_Model.TempWstatus_impl.example())
    api.put_upper_desired_tempWstatus(Isolette_Data_Model.TempWstatus_impl.example())
    api.put_lower_alarm_tempWstatus(Isolette_Data_Model.TempWstatus_impl.example())
    api.put_upper_alarm_tempWstatus(Isolette_Data_Model.TempWstatus_impl.example())
  }

  def timeTriggered(api: operator_interface_thread_impl_Operational_Api): Unit = {

  }

  def activate(api: operator_interface_thread_impl_Operational_Api): Unit = { }

  def deactivate(api: operator_interface_thread_impl_Operational_Api): Unit = { }

  def finalise(api: operator_interface_thread_impl_Operational_Api): Unit = { }

  def recover(api: operator_interface_thread_impl_Operational_Api): Unit = { }
}
