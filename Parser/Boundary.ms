/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ワード境界に一致するパーサ。
@remarks 現在位置の前後において一方が正規表現の`\w`（`[a-zA-Z_0-9]`）、もう一方が`\W`に一致する場合をワード境界とみなす。
*/
struct BoundaryStruct (
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*- @prop <Struct:CharStruct> `[a-zA-Z_0-9]`に一致するパーサ。 */
  private charParser,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Struct:NotCollectStruct|Struct:FailureStruct> 成功した場合は`NotCollectStruct`、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    if context.SOS() or context.EOS() then (
      result = ::NotCollectStruct()
    )
    else (
      context.Seek (startOffset - 1)
      local forward = this.charParser.Parse context
      context.Seek startOffset
      local backward = this.charParser.Parse context
      context.Seek startOffset
      if (classOf forward == ::FailureStruct and classOf backward == String) \
          or (classOf forward == String and classOf backward == ::FailureStruct) do (
        result = ::NotCollectStruct()
      )
    )
    if this.Debug do context.PrintDebugInfo "BoundaryStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #BoundaryStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%BoundaryStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
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

  on Create do (
    this.charParser = (::parserCombinatorDefinitionPool[@"Parser\Char.ms"]) "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"
  )
)
