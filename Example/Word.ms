/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
単語のパーサ。
@remarks
```ebnf
          word = ( alphabet | "_" ) , { ( alphabet | digit | "_" ) }+ ;
      alphabet = upper_alphabet | lower_alphabet ;
upper_alphabet = "A"| "B"| "C"| "D"| "E"| "F"| "G"| "H"| "I"| "J"| "K"| "L"| "M"| "N"| "O"| "P"| "Q"| "R"| "S"| "T"| "U"| "V"| "W"| "X"| "Y"| "Z" ;
lower_alphabet = "a"| "b"| "c"| "d"| "e"| "f"| "g"| "h"| "i"| "j"| "k"| "l"| "m"| "n"| "o"| "p"| "q"| "r"| "s"| "t"| "u"| "v"| "w"| "x"| "y"| "z" ;
         digit = "0"| "1"| "2"| "3"| "4"| "5"| "6"| "7"| "8"| "9" ;
```
*/
struct WordStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*-
  @param input <String>
  @returns <String|Struct:FailureStruct> 成功した場合は文字列、失敗した場合は`FailureStruct`を返す。
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
      this.pc.Sequence #(
        this.pc.Choice #(this.pc.Alphabet(), this.pc.Char "_"),
        this.pc.Many (
          this.pc.Choice #(
            this.pc.Alphabet(),
            this.pc.Digit(),
            this.pc.Char "_"
          )
        ) minCount:1
      )
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #WordStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%WordStruct\n" indent to:out
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
