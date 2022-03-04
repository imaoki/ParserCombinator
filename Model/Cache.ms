/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
メモ化のためのキャッシュデータ。
*/
struct CacheStruct (
  /*- @prop <Dictionary Key:<String> Value:<Any>> */
  private data = Dictionary #String,

  /*-
  キャッシュをクリアする。
  @returns <OkClass>
  */
  public fn Clear = (
    free this.data
    this.data = Dictionary #String
    ok
  ),

  /*-
  パース結果をキャッシュから読み取る。
  @param parser <Struct> メモ化対象のパーサのインスタンス。
  @param start <Integer> 開始位置。
  @returns <DataPair Hit:<BooleanClass> Cache:<DataPair End:<Integer> Value:<Any>|UndefinedClass>> キャッシュが存在した場合は`Hit`が`true`になる。
  */
  public fn Read parser start = (
    local result = DataPair Hit:false Cache:undefined
    local key = this.generateKey parser start
    result.Hit = hasDictValue this.data key
    if result.Hit do (
      result.Cache = this.data[key]
    )
    result
  ),

  /*-
  パース結果をキャッシュに書き込む。
  @param parser <Struct> メモ化対象のパーサのインスタンス。
  @param start <Integer> 開始位置。
  @param end <Integer> 終了位置。
  @param result <Any> メモ化対象のパーサのパース結果。
  @returns <OkClass>
  */
  public fn Write parser start end result = (
    local key = this.generateKey parser start
    this.data[key] = DataPair End:end Value:result
    ok
  ),

  /*-
  @param parser <Struct>
  @param start <Integer>
  @returns <String>
  */
  private fn generateKey parser start = (
    with printAllElements true parser as String + ":" + start as String
  ),

  /*- @returns <Name> */
  public fn StructName = #CacheStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%CacheStruct\n" indent to:out
    format "%  data:%\n" indent this.data.Count to:out
    for key in this.data.Keys do (
      local keyText = ::std.StringUtility.EscapeBackslash key
      local valueText = this.data[key]
      if classOf v == String then (
        valueText = ::std.StringUtility.EscapeBackslash valueText
      )
      else (
        valueText = ::std.StringUtility.ToPascalCase valueText
        valueText = ::std.StringUtility.EscapeBackslash valueText
      )
      format "%    [\"%\"]:\"%\"\n" indent keyText valueText to:out
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
