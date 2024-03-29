/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
実数のパーサ。
@remarks
```ebnf
  number = [ "-" ] , integral , [ fraction ] , [ exponent ] ;
integral = zero | onenine , { digit } ;
fraction = "." , { digit }+ ;
exponent = ( "E" | "e" ) , [ sign ] , { digit }+ ;
   digit = zero | onenine ;
    zero = "0" ;
 onenine = "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" ;
    sign = "+" | "-" ;
```
*/
struct NumberStruct (
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
  @returns <Number|Struct:FailureStruct> 成功した場合は実数、失敗した場合は`FailureStruct`を返す。
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
      this.pc.Sequence #(
        this.pc.Map (this.pc.Option (this.pc.Char "-")) this.signAsInteger,
        this.pc.Map (
          this.pc.Join (
            this.pc.Sequence #(
              this.integral(),
              this.pc.Option (this.fraction()),
              this.pc.Option (this.exponent())
            )
          )
        ) this.numberAsInteger
      )
    ) this.applySign
  ),

  /*-
  @returns <Struct>
  */
  private fn integral = (
    this.pc.Choice #(
      this.zero(),
      this.pc.Sequence #(
        this.onenine(),
        this.pc.Many (this.digit())
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn fraction = (
    this.pc.Sequence #(
      this.pc.Char ".",
      this.pc.Many (this.digit()) minCount:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn exponent = (
    this.pc.Sequence #(
      this.pc.Char "Ee",
      this.pc.Option (this.sign()),
      this.pc.Many (this.digit()) minCount:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn digit = (
    this.pc.Choice #(this.zero(), this.onenine())
  ),

  /*-
  @returns <Struct>
  */
  private fn zero = (
    this.pc.Char "0"
  ),

  /*-
  @returns <Struct>
  */
  private fn onenine = (
    this.pc.Char "123456789"
  ),

  /*-
  @returns <Struct>
  */
  private fn sign = (
    this.pc.Char "+-"
  ),

  /*-
  @param result <Array[<Any>]|Struct:FailureStruct>
  @returns <Integer|Struct:FailureStruct>
  */
  private fn applySign result = (
    if classOf result == Array \
        and result.Count == 2 \
        and classOf result[1] == Integer \
        and superClassOf result[2] == Number then (
      result[2] * result[1]
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  @param result <Any|Struct:FailureStruct>
  @returns <Integer|Struct:FailureStruct>
  */
  private fn numberAsInteger result = (
    if classOf result == String then (
      result as Number
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  @param result <Any|Struct:FailureStruct>
  @returns <Integer>
  */
  private fn signAsInteger result = (
    if result == "-" then -1 else 1
  ),

  /*- @returns <Name> */
  public fn StructName = #NumberStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%NumberStruct\n" indent to:out
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
