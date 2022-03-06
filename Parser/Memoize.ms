/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
パーサをメモ化する。
*/
struct Memoize (
  /*- @prop <Struct> */
  public Parser,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local cacheData = context.ReadCache this.Parser
    if cacheData.Hit then (
      context.Seek cacheData.Cache.End
      result = cacheData.Cache.Value
    )
    else (
      local startOffset = context.GetOffset()
      result = this.Parser.Parse context
      local endOffset = context.GetOffset()
      context.WriteCache this.Parser startOffset endOffset result
    )
    if this.Debug do context.PrintDebugInfo "Memoize" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #Memoize,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%Memoize\n" indent to:out
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
