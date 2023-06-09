// #Sireum
package report

import org.sireum._
import org.sireum.cli.HAMR
import org.sireum.hamr.codegen.common.properties.PropertyUtil
import org.sireum.hamr.codegen.common.symbols.{SymbolResolver, SymbolTable, SymbolUtil}
import org.sireum.hamr.codegen.common.transformers.Transformers
import org.sireum.hamr.codegen.common.types.TypeResolver
import org.sireum.hamr.ir
import org.sireum.hamr.ir.{JSON, MsgPack}
import org.sireum.message.Reporter

object AadlModelUtil {

  def getModel(inputFile: Os.Path, isMsgpack: B): ir.Aadl = {
    val input: String = if (inputFile.exists && inputFile.isFile) {
      inputFile.read
    } else {
      halt(s"AIR input file ${inputFile} not found")
    }

    val model: ir.Aadl = if (isMsgpack) {
      org.sireum.conversions.String.fromBase64(input) match {
        case Either.Left(u) =>
          MsgPack.toAadl(u) match {
            case Either.Left(m) => m
            case Either.Right(m) =>
              halt(s"MsgPack deserialization error at offset ${m.offset}: ${m.message}")
          }
        case Either.Right(m) =>
          halt(m)
      }
    }
    else {
      JSON.toAadl(input) match {
        case Either.Left(m) => m
        case Either.Right(m) =>
          halt(s"Json deserialization error at (${m.line}, ${m.column}): ${m.message}")
      }
    }
    return model
  }

  def getSymbolTable(model: ir.Aadl, basePackageName: String, o: Cli.SireumHamrCodegenOption): SymbolTable = {
    val reporter = Reporter.create

    var _model = model

    val result = ir.Transformer(Transformers.MissingTypeRewriter()).transformAadl(Transformers.CTX(F, ISZ()), _model)
    _model = if (result.resultOpt.nonEmpty) result.resultOpt.get else model

    val rawConnections: B = PropertyUtil.getUseRawConnection(_model.components(0).properties)
    val aadlTypes = TypeResolver.processDataTypes(_model, rawConnections, o.maxStringSize, o.bitWidth, basePackageName, reporter)

    val aadlMaps = SymbolUtil.buildAadlMaps(_model, reporter)

    val s = SymbolResolver.resolve(_model, aadlTypes, aadlMaps, HAMR.toCodeGenOptions(o), reporter)
    if (reporter.hasError) {
      println("**********************************************")
      println("***  Messages from AadlModelUtil")
      println("**********************************************")
      reporter.printMessages()
      println("**********************************************")
      println("***  END OF Messages from AadlModelUtil")
      println("**********************************************")

    }
    return s.get
  }
}
