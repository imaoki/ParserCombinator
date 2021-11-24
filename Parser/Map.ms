/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサの結果を加工するパーサ。
*/
struct MapStruct (
  /*- @prop <Struct> */
  public Parser,
  /*- @prop <MAXScriptFunction> パーサの結果を引数に取る加工用の関数。 */
  public Callback,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合は加工結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = this.Parser.Parse context
    if classOf result != ::FailureStruct \
        and classOf this.Callback == MAXScriptFunction do (
      result = this.Callback result
    )
    if this.Debug do context.PrintDebugInfo "MapStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #MapStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MapStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Callback:%\n" indent (classOf this.Callback) to:out
    format "%  Parser:\n" indent to:out
    this.Parser.Dump indent:(indent + "    ") out:out
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    local isEqualProperties = true

    isEqualStructName and isEqualProperties
  ),

  on Create do ()
)
