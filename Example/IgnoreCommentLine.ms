/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
コメント行を無視するパーサ。
@remarks
```ebnf
       expr = { ( ignore | line ) } ;
     ignore = { "#" , line } ;
single_line = { any_char - new_line } , [ new_line ] ;
   new_line = "\r\n" | "\r" | "\n" ;
```
*/
struct InlineCommentStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @param input <String>
  @returns <String> 常に文字列を返す。
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
    this.pc.Join (
      this.pc.Many (
        this.pc.Choice #(
          this.ignore(),
          this.singleLine()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn ignore = (
    this.pc.Skip (
      this.pc.AndAlso #(
        this.pc.Char "#",
        this.singleLine()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn singleLine = (
    this.pc.Sequence #(
      this.pc.Many (
        this.pc.ItemAt (
          this.pc.Sequence #(
            this.pc.IsNot (this.newLine()),
            this.pc.AnyChar()
          )
        ) -1
      ),
      this.pc.Option (this.newLine())
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn newLine = (
    this.pc.Choice #(
      this.pc.Token "\r\n",
      this.pc.Char "\r\n"
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #InlineCommentStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%InlineCommentStruct\n" indent to:out
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
    this.parser = this.expr()
  )
)
