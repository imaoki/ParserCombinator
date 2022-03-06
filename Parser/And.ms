/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
与えられたパーサが全て成功した時、最後のパーサの結果を返すパーサ。
@remarks
最後以外のパーサが成功している間は解析対象の文字列を消費しない。
もし最後以外のパーサが失敗するとその時点でパース失敗となる。

トークンの頭文字に一致する
:   ```maxscript
    (
      local parser = AndStruct #(
        (ChoiceStruct #((TokenStruct "foo"), (TokenStruct "bar"))),
        (AnyCharStruct())
      )
      parser (ContextStruct "foo")
    )
    -- 結果
    f
    ```

`d`以外の文字に一致する
:   ```maxscript
    (
      local parser = ManyStruct (
        AndStruct #(
          (IsNotStruct (CharStruct "d")),
          (AnyCharStruct())
        )
      )
      parser (ContextStruct "abcd")
    )
    -- 結果
    #("a", "b", "c")
    ```

*/
struct AndStruct (
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
    local parserCount = this.Parsers.Count
    local isSuccessful = parserCount > 0
    for i = 1 to parserCount - 1 while isSuccessful do (
      isSuccessful = classOf (this.Parsers[i].Parse context) != ::FailureStruct
      context.Seek offset
    )
    if isSuccessful do (
      result = this.Parsers[parserCount].Parse context
    )
    if this.Debug do context.PrintDebugInfo "AndStruct" startOffset result
    result
  ),

  /*- @returns <Name> */
  public fn StructName = #AndStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%AndStruct\n" indent to:out
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
