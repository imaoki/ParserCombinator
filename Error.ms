/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
エラー情報を記録する。
*/
struct ErrorStruct (
  /*- @prop <String> 期待する文字列。 */
  public Expected = "",
  /*- @prop <Integer> エラーが発生した行数。 */
  public LineNumber = 0,
  /*- @prop <String> エラーが発生した行の文字列。 */
  public LineText = "",
  /*- @prop <Integer> エラーが発生した位置。 */
  public Offset = -1,
  /*- @prop <String> エラーが発生した位置の文字。 */
  public OffsetChar = "",

  /*-
  エラー情報をクリアする。
  @returns <OkClass>
  */
  public fn Clear = (
    this.Expected = ""
    this.LineNumber = 0
    this.LineText = ""
    this.Offset = -1
    this.OffsetChar = ""
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #ErrorStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ErrorStruct\n" indent to:out
    format "%  Expected:\"%\"\n" indent (::stringUtility.EscapeBackslash this.Expected) to:out
    format "%  LineNumber:%\n" indent this.LineNumber to:out
    format "%  LineText:\"%\"\n" indent (::stringUtility.EscapeBackslash this.LineText) to:out
    format "%  Offset:%\n" indent this.Offset to:out
    format "%  OffsetChar:\"%\"\n" indent (::stringUtility.EscapeBackslash this.OffsetChar) to:out
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
