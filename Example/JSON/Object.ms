/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
オブジェクトのパーサ。
@remarks
```ebnf
 object = "{" , ( members | whitespace ) , "}" ;
members = member , { "," , member } ;
 member = [ whitespace ] , string , [ whitespace ] , ":" , element ;
element = [ whitespace ] , value , [ whitespace ] ;
```
*/
struct ObjectStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <Struct:StringStruct> */
  private stringParser,
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
  @returns <Dictionary <String> <Any>|Struct:FailureStruct> 成功した場合は`Dictionary`値、失敗した場合は`FailureStruct`を返す。
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
      this.pc.Flatten (
        this.pc.Sequence #(
          this.pc.Skip (this.pc.Char "{"),
          this.pc.Choice #(
            this.members(),
            this.whitespace()
          ),
          this.pc.Skip (this.pc.Expect (this.pc.Char "}") expected:"}")
        )
      ) depth:1
    ) this.asDictionary
  ),

  /*-
  @returns <Struct>
  */
  private fn members = (
    this.pc.List (this.member()) (this.pc.Char ",")
  ),

  /*-
  @returns <Struct>
  */
  private fn member = (
    this.pc.Sequence #(
      this.whitespace(),
      this.pc.Delay this.string,
      this.whitespace(),
      this.pc.Skip (this.pc.Expect (this.pc.Char ":") expected:":"),
      this.pc.Expect (this.element()) expected:"<element>"
    )
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
  private fn string = (
    this.stringParser.GetParser()
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

  /*-
  @param result <Array[<Array[<Any>]>]>
  @returns <Dictionary <String> <Any>|Struct:FailureStruct>
  @remarks キーが重複している場合は上書きされる。
  */
  private fn asDictionary result = (
    if this.canConvertToDictionary result then (
      local dict = Dictionary #String
      for pair in result do (
        PutDictValue dict pair[1] pair[2]
      )
      dict
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  オブジェクトが`Dictionary`値に変換可能かどうかを判定する。
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn canConvertToDictionary obj = (
    local canConvert = classOf obj == Array
    if canConvert do (
      for elem in obj while canConvert do (
        canConvert = classOf elem == Array \
            and elem.Count == 2 \
            and classOf elem[1] == ::String
      )
    )
    canConvert
  ),

  /*- @returns <Name> */
  public fn StructName = #ObjectStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ObjectStruct\n" indent to:out
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
    local pathUtility = ::PathUtilityStruct (getSourceFileName())
    this.pc = (fileIn (pathUtility.GetFullPath @"..\..\ParserCombinator.ms"))()
    this.stringParser = (fileIn "String.ms")()
    this.valueParserDef = fileIn "Value.ms"
    this.whiteSpaceParser = (fileIn "WhiteSpace.ms")()
    this.parser = this.expr()
  )
)
