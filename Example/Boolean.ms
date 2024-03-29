/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ブール値のパーサ。
@remarks
```ebnf
boolean = "true" | "false" ;
```
*/
struct BooleanStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @returns <Struct>
  */
  public fn GetParser = (
    this.parser
  ),

  /*-
  @param input <String>
  @returns <BooleanClass|Struct:FailureStruct> 成功した場合は真偽値、失敗した場合は`FailureStruct`を返す。
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
    this.pc.Map (
      this.pc.Choice #(
        this.pc.Token "true",
        this.pc.Token "false"
      )
    ) this.asBoolean
  ),

  /*-
  @param result <Any|Struct:FailureStruct>
  @returns <BooleanClass|Struct:FailureStruct>
  */
  private fn asBoolean result = (
    if classOf result == String then (
      result as BooleanClass
    )
    else (
      ::FailureStruct()
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #BooleanStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%BooleanStruct\n" indent to:out
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
