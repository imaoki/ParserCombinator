/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサの結果を配列として返すパーサ。
@remarks パーサが一つでも失敗した場合はこのパーサも失敗する。
*/
struct SequenceStruct (
  /*- @prop <Array[<Struct>]> */
  public Parsers = #(),
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Array[<Any>]|Struct:FailureStruct> 成功した場合はパース結果の配列、失敗した場合は`FailureStruct`を返す。
  @remarks パース結果が`NotCollectStruct`の場合は配列から除外する。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local isSuccessful = true
    local results = for p in this.Parsers while isSuccessful collect (
      local parserResult = p.Parse context
      isSuccessful = classOf parserResult != ::FailureStruct
      if isSuccessful then (
        -- `NotCollectStruct`の場合は収集しない
        if classOf parserResult == ::NotCollectStruct then (
          dontCollect
        )
        else (
          parserResult
        )
      )
      else (
        dontCollect
      )
    )
    if isSuccessful do (
      result = results
    )
    if this.Debug do context.PrintDebugInfo "SequenceStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #SequenceStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%SequenceStruct\n" indent to:out
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
