/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
成功を期待するパーサが失敗した場合にエラーを記録するパーサ。
*/
struct ExpectStruct (
  /*- @prop <Struct> */
  public Parser,
  /*-
  @prop <String> 期待する構文規則。既定値は`""`。
  @remarks エスケープシーケンスは予めエスケープすること。
  */
  public Expected = "",
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local offset = copy startOffset
    local result = this.Parser.Parse context
    if classOf result == ::FailureStruct do (
      context.LogError offset this.Expected
    )
    if this.Debug do context.PrintDebugInfo "ExpectStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #ExpectStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ExpectStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    -- エスケープシーケンスがエスケープされている前提
    format "%  Expected:\"%\"\n" indent this.Expected to:out
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
