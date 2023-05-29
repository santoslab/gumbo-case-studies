// #Sireum

package RTS.Actuation

import org.sireum._
import art.{Art, ArtNative, Empty}
import RTS._

// This file was auto-generated.  Do not edit
@msig trait Actuator_i_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator_TestApi {

  def BeforeEntrypoint(): Unit = {
    Art.initTest(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator)
  }

  def AfterEntrypoint(): Unit = {
    Art.finalizeTest(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator)
  }

  def testCompute(): Unit = {
    Art.manuallyClearOutput()
    Art.testCompute(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator)
  }

  def testInitialise(): Unit = {
    Art.manuallyClearOutput()
    Art.testInitialise(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator)
  }

  /** helper function to set the values of all input ports.
   * @param input payload for data port input
   * @param manualActuatorInput payload for data port manualActuatorInput
   */
  def put_concrete_inputs(input : Base_Types.Boolean,
                          manualActuatorInput : Base_Types.Boolean): Unit = {
    put_input(input)
    put_manualActuatorInput(manualActuatorInput)
  }


  /** helper function to check Actuator_i_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator's
   * output ports.  Use named arguments to check subsets of the output ports.
   * @param output method that will be called with the value of the outgoing data
   *        port 'output'.
   */
  def check_concrete_output(output: Base_Types.Boolean => B): Unit = {
    var testFailures: ISZ[ST] = ISZ()

    val outputValue: Base_Types.Boolean = get_output().get
    if(!output(outputValue)) {
      testFailures = testFailures :+ st"'output' did not match expected: value of the outgoing data port is ${outputValue}"
    }

    assert(testFailures.isEmpty, st"${(testFailures, "\n")}".render)
  }


  // setter for in DataPort
  def put_input(value : Base_Types.Boolean): Unit = {
    ArtNative.insertInPortValue(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator.operational_api.input_Id, Base_Types.Boolean_Payload(value))
  }

  // setter for in DataPort
  def put_manualActuatorInput(value : Base_Types.Boolean): Unit = {
    ArtNative.insertInPortValue(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator.operational_api.manualActuatorInput_Id, Base_Types.Boolean_Payload(value))
  }

  // getter for out DataPort
  def get_output(): Option[Base_Types.Boolean] = {
    val value: Option[Base_Types.Boolean] = get_output_payload() match {
      case Some(Base_Types.Boolean_Payload(v)) => Some(v)
      case Some(v) => halt(s"Unexpected payload on port output.  Expecting 'Base_Types.Boolean_Payload' but received ${v}")
      case _ => None[Base_Types.Boolean]()
    }
    return value
  }

  // payload getter for out DataPort
  def get_output_payload(): Option[Base_Types.Boolean_Payload] = {
    return ArtNative.observeOutPortValue(Arch.RTS_i_Instance_actuationSubsystem_saturationActuatorUnit_saturationActuator_actuator.initialization_api.output_Id).asInstanceOf[Option[Base_Types.Boolean_Payload]]
  }

}
