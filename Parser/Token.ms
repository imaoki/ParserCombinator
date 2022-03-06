/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
入力文字列に一致するパーサ。
*/
struct TokenStruct (
  /*- @prop <String> */
  public Pattern = "",
  /*- @prop <BooleanClass> 大文字と小文字を区別しない場合は`true`、区別する場合は`false`。既定値は`true`。 */
  public IgnoreCase = true,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <String|Struct:FailureStruct> 成功した場合は一致した文字列、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local str = context.Read this.Pattern.Count
    if (this.IgnoreCase and stricmp str this.Pattern == 0) \
        or (not this.IgnoreCase and str == this.Pattern) do (
      result = str
    )
    if this.Debug do context.PrintDebugInfo "TokenStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #TokenStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%TokenStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Pattern:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.Pattern) to:out
    format "%  IgnoreCase:%\n" indent this.IgnoreCase to:out
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
