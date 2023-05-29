// #Sireum

package RTS.EventControl

import org.sireum._
import art._
import RTS._
import RTS.EventControl.{EventControlMockThread_i_eventControlMock_eventControlMockThread => component}

// This file was auto-generated.  Do not edit

@datatype class EventControlMockThread_i_eventControlMock_eventControlMockThread_Bridge(
  val id: Art.BridgeId,
  val name: String,
  val dispatchProtocol: DispatchPropertyProtocol,
  val dispatchTriggers: Option[ISZ[Art.PortId]],

  manualActuatorInput1: Port[Base_Types.Boolean],
  manualActuatorInput2: Port[Base_Types.Boolean]
  ) extends Bridge {

  val ports : Bridge.Ports = Bridge.Ports(
    dataIns = ISZ[art.UPort](),

    dataOuts = ISZ[art.UPort](manualActuatorInput1,
                              manualActuatorInput2),

    eventIns = ISZ[art.UPort](),

    eventOuts = ISZ[art.UPort]()
  )

  val initialization_api : EventControlMockThread_i_Initialization_Api = {
    val api = EventControlMockThread_i_Initialization_Api(
      id,
      manualActuatorInput1.id,
      manualActuatorInput2.id
    )
    EventControlMockThread_i_eventControlMock_eventControlMockThread_Bridge.c_initialization_api = Some(api)
    api
  }

  val operational_api : EventControlMockThread_i_Operational_Api = {
    val api = EventControlMockThread_i_Operational_Api(
      id,
      manualActuatorInput1.id,
      manualActuatorInput2.id
    )
    EventControlMockThread_i_eventControlMock_eventControlMockThread_Bridge.c_operational_api = Some(api)
    api
  }

  val entryPoints : Bridge.EntryPoints =
    EventControlMockThread_i_eventControlMock_eventControlMockThread_Bridge.EntryPoints(
      id,

      manualActuatorInput1.id,
      manualActuatorInput2.id,

      dispatchTriggers,

      initialization_api,
      operational_api)
}

object EventControlMockThread_i_eventControlMock_eventControlMockThread_Bridge {

  var c_initialization_api: Option[EventControlMockThread_i_Initialization_Api] = None()
  var c_operational_api: Option[EventControlMockThread_i_Operational_Api] = None()

  @datatype class EntryPoints(
    EventControlMockThread_i_eventControlMock_eventControlMockThread_BridgeId : Art.BridgeId,
    manualActuatorInput1_Id : Art.PortId,
    manualActuatorInput2_Id : Art.PortId,
    dispatchTriggers : Option[ISZ[Art.PortId]],
    initialization_api: EventControlMockThread_i_Initialization_Api,
    operational_api: EventControlMockThread_i_Operational_Api) extends Bridge.EntryPoints {

    val dataInPortIds: ISZ[Art.PortId] = IS()

    val eventInPortIds: ISZ[Art.PortId] = IS()

    val dataOutPortIds: ISZ[Art.PortId] = IS(manualActuatorInput1_Id,
                                             manualActuatorInput2_Id)

    val eventOutPortIds: ISZ[Art.PortId] = IS()

    def initialise(): Unit = {
      // implement the following method in 'component':  def initialise(api: EventControlMockThread_i_Initialization_Api): Unit = {}
      component.initialise(initialization_api)
      Art.sendOutput(eventOutPortIds, dataOutPortIds)
    }

    def compute(): Unit = {
      Art.receiveInput(eventInPortIds, dataInPortIds)

      // implement the following in 'component':  def timeTriggered(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.timeTriggered(operational_api)

      Art.sendOutput(eventOutPortIds, dataOutPortIds)
    }

    def activate(): Unit = {
      // implement the following method in 'component':  def activate(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.activate(operational_api)
    }

    def deactivate(): Unit = {
      // implement the following method in 'component':  def deactivate(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.deactivate(operational_api)
    }

    def finalise(): Unit = {
      // implement the following method in 'component':  def finalise(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.finalise(operational_api)
    }

    def recover(): Unit = {
      // implement the following method in 'component':  def recover(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.recover(operational_api)
    }

    override
    def testInitialise(): Unit = {
      // implement the following method in 'component':  def initialise(api: EventControlMockThread_i_Initialization_Api): Unit = {}
      component.initialise(initialization_api)
      Art.releaseOutput(eventOutPortIds, dataOutPortIds)
    }

    override
    def testCompute(): Unit = {
      Art.receiveInput(eventInPortIds, dataInPortIds)

      // implement the following in 'component':  def timeTriggered(api: EventControlMockThread_i_Operational_Api): Unit = {}
      component.timeTriggered(operational_api)

      Art.releaseOutput(eventOutPortIds, dataOutPortIds)
    }
  }
}