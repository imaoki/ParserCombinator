/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
どのような一文字にも一致するパーサ。
*/
struct AnyCharStruct (
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <String|Struct:FailureStruct> 成功した場合は一致した文字列、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    if not context.EOS() do (
      result = context.Read 1
    )
    if this.Debug do context.PrintDebugInfo "AnyCharStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #AnyCharStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%AnyCharStruct\n" indent to:out
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

  on Create do ()
)
