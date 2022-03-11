/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
値のパーサ。
@remarks
```ebnf
value = [ whitespace ] , ( object | array | string | number | boolean | "null" ) , [ whitespace ] ;
```
*/
struct ValueStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <Struct:ArrayStruct> */
  private arrayParser,
  /*- @prop <Struct:BooleanStruct> */
  private booleanParser,
  /*- @prop <Struct:NumberStruct> */
  private numberParser,
  /*- @prop <Struct:ObjectStruct> */
  private objectParser,
  /*- @prop <Struct:StringStruct> */
  private stringParser,
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
    this.pc.ItemAt (
      this.pc.Sequence #(
        this.whitespace(),
        this.pc.Choice #(
          this.object(),
          this.array(),
          this.string(),
          this.number(),
          this.boolean(),
          this.null()
        ),
        this.whitespace()
      )
    ) -1
  ),

  /*-
  @returns <Struct>
  */
  private fn whitespace = (
    this.whiteSpaceParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn object = (
    this.objectParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn array = (
    this.arrayParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn string = (
    this.stringParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn number = (
    this.numberParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn boolean = (
    this.booleanParser.GetParser()
  ),

  /*-
  @returns <Struct>
  */
  private fn null = (
    this.pc.Map (this.pc.Token "null") this.nullAsUndefined
  ),

  /*-
  @param result <String|Struct:FailureStruct>
  @returns <UndefinedClass|Struct:FailureStruct>
  */
  private fn nullAsUndefined result = (
    if classOf result == ::String then (
      undefined
    )
    else (
      ::FailureStruct()
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #ValueStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ValueStruct\n" indent to:out
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
    this.pc = ::ParserCombinatorStruct()
    this.arrayParser = (fileIn @"Array.ms")()
    this.booleanParser = (fileIn (pathUtility.GetFullPath @"..\Boolean.ms"))()
    this.numberParser = (fileIn @"Number.ms")()
    this.objectParser = (fileIn @"Object.ms")()
    this.stringParser = (fileIn @"String.ms")()
    this.whiteSpaceParser = (fileIn @"WhiteSpace.ms")()
    this.parser = this.expr()
  )
)
