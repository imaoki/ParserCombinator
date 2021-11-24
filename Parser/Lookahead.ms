/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
先読みパーサ。
@remarks
2番目以降のパーサが成功した時、1番目のパーサの結果を返す。
解析対象の文字列は1番目のパーサ分だけ消費する。
失敗した場合は解析対象の文字列を消費しない。
*/
struct LookaheadStruct (
  /*- @prop <Array[<Struct>]> */
  public Parsers = #(),
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  @remarks パーサが一つの場合は失敗する。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local parserCount = this.Parsers.Count
    local isSuccessful = parserCount > 1
    if isSuccessful do (
      local offset1 = copy startOffset
      result = this.Parsers[1].Parse context
      local offset2 = context.GetOffset()
      isSuccessful = classOf result != ::FailureStruct
      for i = 2 to parserCount while isSuccessful do (
        isSuccessful = classOf (this.Parsers[i].Parse context) != ::FailureStruct
        context.Seek offset2
      )
      if not isSuccessful do (
        result = ::FailureStruct()
        context.Seek offset1
      )
    )
    if this.Debug do context.PrintDebugInfo "LookaheadStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #LookaheadStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%LookaheadStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Parsers:%\n" indent this.Parsers.Count to:out
    for i = 1 to this.Parsers.Count do (
      format "%    [%]\n" indent i to:out
      this.Parsers[i].Dump indent:(indent + "      ") out:out
    )
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
