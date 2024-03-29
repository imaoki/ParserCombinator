/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
空白文字列のパーサ。
@remarks
```ebnf
   array = "[" , ( elements | whitespace ) , "]" ;
elements = element , { "," , element } ;
 element = [ whitespace ] , value , [ whitespace ] ;
```
*/
struct ArrayStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <StructDef:ValueStruct> */
  private valueParserDef,
  /*- @prop <Struct:WhiteSpaceStruct> */
  private whiteSpaceParser,

  /*-
  @returns <Struct>
  */
  public fn GetParser = (
    this.parser
  ),

  /*-
  @param input <String>
  @returns <Array[<Any>]|Struct:FailureStruct> 成功した場合は配列、失敗した場合は`FailureStruct`を返す。
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
    this.pc.Flatten (
      this.pc.Sequence #(
        this.pc.Skip (this.pc.Char "["),
        this.pc.Choice #(
          this.elements(),
          this.whitespace()
        ),
        this.pc.Skip (this.pc.Expect (this.pc.Char "]") expected:"]")
      )
    ) depth:1
  ),

  /*-
  @returns <Struct>
  */
  private fn elements = (
    this.pc.List (this.element()) (this.pc.Char ",")
  ),

  /*-
  @returns <Struct>
  */
  private fn element = (
    this.pc.ItemAt (
      this.pc.Sequence #(
        this.whitespace(),
        this.pc.Delay this.value,
        this.whitespace()
      )
    ) -1
  ),

  /*-
  @returns <Struct>
  */
  private fn value = (
    (this.valueParserDef()).GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn whitespace = (
    this.whiteSpaceParser.GetParser()
  ),

  /*- @returns <Name> */
  public fn StructName = #ArrayStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ArrayStruct\n" indent to:out
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
    this.valueParserDef = fileIn @"Value.ms"
    this.whiteSpaceParser = (fileIn @"WhiteSpace.ms")()
    this.parser = this.expr()
  )
)
