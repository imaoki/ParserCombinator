/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサが失敗した場合でも`NotCollectStruct`を返す（成功となる）パーサ。
*/
struct OptionStruct (
  /*- @prop <Struct> */
  public Parser,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:NotCollectStruct> 成功した場合はパース結果、失敗した場合は`NotCollectStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local offset = copy startOffset
    local result = this.Parser.Parse context
    if classOf result == ::FailureStruct do (
      context.Seek offset
      result = ::NotCollectStruct()
    )
    if this.Debug do context.PrintDebugInfo "OptionStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #OptionStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%OptionStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
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
