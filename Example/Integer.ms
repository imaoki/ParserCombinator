/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
整数のパーサ。
@remarks
```ebnf
          expr = [ sign ] , ( zero_digit | ( non_zero_digit , { digit } ) ) ;
          sign = "-" | "+" ;
         digit = zero_digit | non_zero_digit ;
non_zero_digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
    zero_digit = "0" ;
```
*/
struct IntegerStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @param input <String>
  @returns <Integer|Struct:FailureStruct> 成功した場合は整数、失敗した場合は`FailureStruct`を返す。
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
        this.pc.Option (this.sign()),
        this.pc.Map (
          this.pc.Join (
            this.pc.Choice #(
              this.zeroDigit(),
              this.pc.Sequence #(
                this.nonZeroDigit(),
                this.pc.Many (
                  this.digit()
                )
              )
            )
          )
        ) this.digitAsInteger
      )
    ) this.applySign
  ),

  /*-
  @returns <Struct>
  */
  private fn sign = (
    this.pc.Map (
      this.pc.Option (
        this.pc.Char "-+"
      )
    ) this.signAsInteger
  ),

  /*-
  @returns <Struct>
  */
  private fn digit = (
    this.pc.Choice #(
      this.zeroDigit(),
      this.nonZeroDigit()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn nonZeroDigit = (
    this.pc.Char "123456789"
  ),

  /*-
  @returns <Struct>
  */
  private fn zeroDigit = (
    this.pc.Char "0"
  ),

  /*-
  @param result <Array[<Any>]|Struct:FailureStruct>
  @returns <Integer|Struct:FailureStruct>
  */
  private fn applySign result = (
    if classOf result == Array \
        and result.Count == 2 \
        and classOf result[1] == Integer \
        and classOf result[2] == Integer then (
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
  private fn digitAsInteger result = (
    if classOf result == String then (
      result as Integer
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
  public fn StructName = #IntegerStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%IntegerStruct\n" indent to:out
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
