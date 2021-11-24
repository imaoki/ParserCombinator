/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
入力したパーサが成功すれば失敗し、失敗すれば成功するパーサ。
@remarks 解析対象の文字列を消費しない。
*/
struct IsNotStruct (
  /*- @prop <Struct> */
  public Parser,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Struct:NotCollectStruct|Struct:FailureStruct> 成功した場合は`NotCollectStruct`、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local offset = copy startOffset
    local result = this.Parser.Parse context
    if classOf result == ::FailureStruct then (
      context.Seek offset
      result = ::NotCollectStruct()
    )
    else (
      result = ::FailureStruct()
    )
    if this.Debug do context.PrintDebugInfo "IsNotStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #IsNotStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%IsNotStruct\n" indent to:out
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
