/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサを失敗するまで繰り返し、結果を配列として返すパーサ。
*/
struct ManyStruct (
  /*- @prop <Struct> */
  public Parser,
  /*- @prop <Integer> 最小繰り返し回数。既定値は`0`。 */
  public MinCount = 0,
  /*- @prop <Integer> 最大繰り返し回数。既定値は`2147483647`。 */
  public MaxCount = 2147483647,
  /*- @prop <BooleanClass> */
  public Debug = false,

  /*- @prop <Integer> MAXScriptにおける有効な整数の最大値。 */
  private intMax = 2147483647,

  /*-
  @param content <Struct:ContextStruct>
  @returns <Array[<Any>]|Struct:FailureStruct> 成功した場合はパース結果の配列、失敗した場合は`FailureStruct`を返す。
  @remarks パース結果が`NotCollectStruct`の場合は配列から除外する。
  */
  public fn Parse context = (
    local startOffset = context.GetOffset()
    local result = ::FailureStruct()
    local isSuccessful = true
    local results = for i = 1 to this.MaxCount \
        while not context.EOS() and isSuccessful collect (
      local offset = context.GetOffset()
      local parserResult = this.Parser.Parse context
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
        context.Seek offset
        dontCollect
      )
    )
    if not results.Count < this.MinCount do (
      result = results
    )
    if this.Debug do context.PrintDebugInfo "ManyStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #ManyStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ManyStruct\n" indent to:out
    format "%  Debug:%\n" indent this.Debug to:out
    format "%  MinCount:%\n" indent this.MinCount to:out
    format "%  MaxCount:%\n" indent this.MaxCount to:out
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

  on Create do (
    if this.MaxCount > this.intMax do (
      this.MaxCount = copy this.intMax
    )
  )
)
