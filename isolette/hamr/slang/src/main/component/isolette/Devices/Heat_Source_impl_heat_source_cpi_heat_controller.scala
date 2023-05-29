// #Sireum

package isolette.Devices

import org.sireum._
import isolette._

// This file will not be overwritten so is safe to edit
object Heat_Source_impl_heat_source_cpi_heat_controller {

  def initialise(api: Heat_Source_impl_Initialization_Api): Unit = {
    api.put_heat_out(Isolette_Environment.Heat.byOrdinal(0).get)
  }

  def timeTriggered(api: Heat_Source_impl_Operational_Api): Unit = {
  }

  def activate(api: Heat_Source_impl_Operational_Api): Unit = { }

  def deactivate(api: Heat_Source_impl_Operational_Api): Unit = { }

  def finalise(api: Heat_Source_impl_Operational_Api): Unit = { }

  def recover(api: Heat_Source_impl_Operational_Api): Unit = { }
}
