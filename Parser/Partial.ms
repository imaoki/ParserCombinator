/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
パース結果を加工する関数を部分適用するためのパーサ。
@remarks 加工用関数は第一引数に加工用のパラメータ、第二引数にパース結果を取ること。
*/
struct PartialStruct (
  /*- @prop <MAXScriptFunction> 加工用関数。 */
  public Callback,
  /*- @prop <Any> 加工用関数の引数。 */
  public CallbackParameter,
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
    local result = this.Parser.Parse context
    if classOf result != ::FailureStruct \
        and classOf this.Callback == MAXScriptFunction do (
      result = this.Callback this.CallbackParameter result
    )
    if this.Debug do context.PrintDebugInfo "PartialStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #PartialStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%PartialStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Callback:%\n" indent (classOf this.Callback) to:out
    if classOf this.CallbackParameter == String then (
      format "%  CallbackParameter:%\n" indent (::stringUtility.EscapeBackslash this.CallbackParameter) to:out
    )
    else (
      format "%  CallbackParameter:%\n" indent (::stringUtility.ToPascalCase this.CallbackParameter) to:out
    )
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
