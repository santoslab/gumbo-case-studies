// #Sireum

package isolette.Devices

import org.sireum._
import isolette._

// This file will not be overwritten so is safe to edit
object Temperature_Sensor_impl_temperature_sensor_cpi_thermostat {

  def initialise(api: Temperature_Sensor_impl_Initialization_Api): Unit = {
    api.put_current_tempWstatus(Isolette_Data_Model.TempWstatus_impl.example())
  }

  def timeTriggered(api: Temperature_Sensor_impl_Operational_Api): Unit = {
  }

  def activate(api: Temperature_Sensor_impl_Operational_Api): Unit = { }

  def deactivate(api: Temperature_Sensor_impl_Operational_Api): Unit = { }

  def finalise(api: Temperature_Sensor_impl_Operational_Api): Unit = { }

  def recover(api: Temperature_Sensor_impl_Operational_Api): Unit = { }
}
