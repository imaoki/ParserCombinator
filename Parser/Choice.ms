/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサを順に試して最初に成功した結果を返すパーサ。
*/
struct ChoiceStruct (
  /*- @prop <Array[<Struct>]> */
  public Parsers = #(),
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local offset = copy startOffset
    local result = ::FailureStruct()
    for p in this.Parsers while classOf result == ::FailureStruct do (
      result = p.Parse context
      if classOf result == ::FailureStruct do (
        context.Seek offset
      )
    )
    if this.Debug do context.PrintDebugInfo "ChoiceStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #ChoiceStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ChoiceStruct\n" indent to:out
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
