/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
入力文字列に含まれる一文字に一致するパーサ。
@remarks 大文字と小文字を区別する。
*/
struct CharStruct (
  /*- @prop <String> */
  public Pattern = "",
  /*- @prop <BooleanClass> 一致すると失敗にする場合は`true`、成功にする場合は`false`。既定値は`false`。 */
  public Except = false,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*- @prop <Struct:AnyCharStruct> */
  private anyCharParser,
  /*-
  @prop <Array[<String>]> パターン文字列を一文字ずつ分解した配列。
  @remarks 大文字と小文字を区別し戻り値の型も一定な`findItem`関数をマッチングに使用するための配列。
  */
  private patternChars = #(),

  /*-
  @param content <Struct:ContextStruct>
  @returns <String|Struct:FailureStruct> 成功した場合は一致した文字列、失敗した場合は`FailureStruct`を返す。
  @remarks 大文字と小文字を区別する。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local char = this.anyCharParser.Parse context
    local isMatch = classOf char == String
    if isMatch do (
      local index = findItem this.patternChars char
      isMatch = (this.Except and index == 0) or (not this.Except and index > 0)
    )
    if isMatch do (
      result = char
    )
    if this.Debug do context.PrintDebugInfo "CharStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #CharStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%CharStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Pattern:\"%\"\n" indent (::std.StringUtility.EscapeBackslash this.Pattern) to:out
    format "%  Except:%\n" indent this.Except to:out
    format "%  patternChars:#(" indent to:out
    for i = 1 to this.patternChars.Count do (
      format "%\"%\"" \
          (if i == 1 then "" else ", ") \
          (::std.StringUtility.EscapeBackslash this.patternChars[i]) \
          to:out
    )
    format ")\n" to:out
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
    this.anyCharParser = (::parserCombinatorDefinitionPool[@"Parser\AnyChar.ms"])()
    this.patternChars = ::std.StringUtility.ToCharArray this.Pattern
  )
)
