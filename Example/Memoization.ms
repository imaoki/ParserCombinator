/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
メモ化したパーサとしていないパーサの比較。
@remarks
```ebnf
a = p , "+" , a | p , "-" , a | p ;
p = "(" , a , ")" | "1" ;
```
*/
struct MemoizationStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parserMemoized,
  /*- @prop <Struct> */
  private parserNotMemo,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @param input <String>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn ParseMemoized input = (
    local context = this.pc.Context input
    local result = this.parserMemoized.Parse context
    if this.ShowError do context.PrintError result
    result
  ),

  /*-
  @param input <String>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn ParseNotMemo input = (
    local context = this.pc.Context input
    local result = this.parserNotMemo.Parse context
    if this.ShowError do context.PrintError result
    result
  ),

  /*-
  @returns <Struct>
  */
  private fn aMemoize = (
    this.pc.Memo (
      this.pc.Choice #(
        this.pc.Sequence #(
          this.pMemoize(),
          this.pc.Char "+",
          this.pc.Delay this.aMemoize
        ),
        this.pc.Sequence #(
          this.pMemoize(),
          this.pc.Char "-",
          this.pc.Delay this.aMemoize
        ),
        this.pMemoize()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn aNotMemo = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pNotMemo(),
        this.pc.Char "+",
        this.pc.Delay this.aNotMemo
      ),
      this.pc.Sequence #(
        this.pNotMemo(),
        this.pc.Char "-",
        this.pc.Delay this.aNotMemo
      ),
      this.pNotMemo()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn pMemoize = (
    this.pc.Memo (
      this.pc.Choice #(
        this.pc.Sequence #(
          this.pc.Char "(",
          this.pc.Delay this.aMemoize,
          this.pc.Char ")"
        ),
        this.pc.Char "1"
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn pNotMemo = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pc.Char "(",
        this.pc.Delay this.aNotMemo,
        this.pc.Char ")"
      ),
      this.pc.Char "1"
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #MemoizationStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MemoizationStruct\n" indent to:out
    format "%  ShowError:%\n" indent this.ShowError to:out
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
    local pathUtility = ::std.PathUtilityStruct (getSourceFileName())
    this.pc = (fileIn (pathUtility.GetFullPath @"..\ParserCombinator.ms"))()
    this.parserMemoized = this.aMemoize()
    this.parserNotMemo = this.aNotMemo()
  )
)
