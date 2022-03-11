/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
丸括弧の対応をとる再帰的なパーサ。
@remarks
```ebnf
      expr = { item } ;
     paren = "(" , { paren_item } , ")" ;
paren_item = item - ")" ;
      item = paren | any_char ;
```
*/
struct ParenthesisStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @param input <String>
  @returns <Any|Struct:FailureStruct> 成功した場合はパース結果、失敗した場合は`FailureStruct`を返す。
  */
  public fn Parse input = (
    local context = this.pc.Context input
    local result = this.parser.Parse context
    if this.ShowError do context.PrintError result
    result
  ),

  /*-
  @returns <Struct>
  */
  private fn expr = (
    this.pc.Many (this.item())
  ),

  /*-
  @returns <Struct>
  */
  private fn paren = (
    this.pc.ItemAt (
      this.pc.Sequence #(
        this.pc.Skip (this.pc.Char "("),
        this.pc.Many (this.parenItem()),
        this.pc.Skip (this.pc.Char ")")
      )
    ) -1
  ),

  /*-
  @returns <Struct>
  */
  private fn parenItem = (
    local c = ")"
    this.pc.AndAlso #(
      this.pc.IsNot (this.pc.Char c),
      this.item()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn item = (
    this.pc.Choice #(
      this.pc.Delay this.paren,
      this.pc.AnyChar()
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #ParenthesisStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ParenthesisStruct\n" indent to:out
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
    this.pc = ::ParserCombinatorStruct()
    this.parser = this.expr()
  )
)
