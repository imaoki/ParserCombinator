/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
パーサを遅延評価するパーサ。
*/
struct DelayStruct (
  /*- @prop <MAXScriptFunction> パーサのインスタンスを返す関数値。 */
  public Callback,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse context = (
    (this.Callback()).Parse context
  ),

  /*- @returns <Name> */
  public fn StructName = #DelayStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%DelayStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  Callback:%\n" indent (classOf this.Callback) to:out
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
