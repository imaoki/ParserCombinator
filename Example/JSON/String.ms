/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
文字列リテラルのパーサ。
@remarks
```ebnf
      string = '"' , { character } , '"' ;
   character = any_char - ( '"' | "\" | control_char ) | escape ;
      escape = "\" , ( '"' | "\" | "/" | "b" | "f" | "n" | "r" | "t" ) | code_point ;
  code_point = "\" , "u" , hex , hex , hex , hex ;
         hex = digit
             | "A" | "B" | "C" | "D" | "E" | "F"
             | "a" | "b" | "c" | "d" | "e" | "f"
             ;
       digit = zero | onenine ;
        zero = "0" ;
     onenine = "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" ;
control_char = ? #x0000 - #x001F ? ;
    any_char = ? Any visible characters ? ;
```
*/
struct StringStruct (
  /*- @prop <BooleanClass> */
  public ShowError = false,

  /*- @prop <Struct> */
  private parser,
  /*- @prop <Struct:ParserCombinatorStruct> */
  private pc,

  /*- @prop <Array[<String>]> エスケープシーケンス文字の配列。 */
  private escapedChars = #("\\\"", "\\\\", "\\/", "\\b", "\\f", "\\n", "\\r", "\\t"),
  /*- @prop <Array[<String>]> エスケープ解除した文字の配列。 */
  private unescapedChars = #("\"", "\\", "/", "\b", "\f", "\n", "\r", "\t"),

  /*-
  @returns <Struct>
  */
  public fn GetParser = (
    this.parser
  ),

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
        this.pc.Skip (this.pc.Char "\""),
        this.pc.Many (
          this.character()
        ),
        this.pc.Skip (this.pc.Expect (this.pc.Char "\"") expected:"\"")
      )
    )
  ),

  /*-
  @returns <Struct>
  @remarks `/`はエスケープシーケンスだが慣例的に除外しないものとする。
  */
  private fn character = (
    this.pc.Choice #(
      this.pc.Expect (
        /* this.pc.Diff (this.pc.AnyChar()) (
          this.pc.Choice #(
            this.controlChar(),
            this.pc.Char "\"\\"
          )
        ) debug:false */
        this.pc.AndAlso #(
          this.pc.IsNot (
            this.pc.Choice #(
              this.pc.Char "\"",
              this.pc.Char "\\",
              this.controlChar()
            )
          ),
          this.pc.AnyChar()
        )
      ) expected:"any_char except \" and \\ and control_char" debug:false,
      this.escape()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn escape = (
    this.pc.Choice #(
      this.pc.Map (
        this.pc.Choice #(
          this.pc.Token "\\\"",
          this.pc.Token "\\\\",
          this.pc.Token "\\/",
          this.pc.Token "\\b",
          this.pc.Token "\\f",
          this.pc.Token "\\n",
          this.pc.Token "\\r",
          this.pc.Token "\\t"
        )
      ) this.unescapeEscape,
      this.codePoint()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn codePoint = (
    this.pc.Map (
      this.pc.Join (
        this.pc.ItemAt (
          this.pc.Sequence #(
            this.pc.Token "\\u",
            this.pc.Expect (
              this.pc.Many (
                this.hex()
              ) minCount:4 maxCount:4
            ) expected:"4-digit <hex>"
          )
        ) 2
      )
    ) this.codePointAsChar
  ),

  /*-
  @returns <Struct>
  */
  private fn hex = (
    this.pc.Choice #(
      this.digit(),
      this.pc.Char "ABCDEFabcdef"
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
  private fn controlChar = (
    this.pc.Map (this.pc.AnyChar()) this.isControlCharacter
  ),

  /*-
  コードポイントを対応するユニコード文字に変換する。
  @param result <String|Struct:FailureStruct>
  @returns <String|Struct:FailureStruct>
  */
  private fn codePointAsChar result = (
    if classOf result == String then (
      local codePoint = ("0x" + result) as Integer
      ::stringUtility.FromCodePoint #(codePoint)
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  制御文字以外の場合は失敗にする。
  @param result <String|Struct:FailureStruct>
  @returns <String|Struct:FailureStruct>
  */
  private fn isControlCharacter result = (
    if classOf result == String and Bit.CharAsInt result < 20 then (
      result
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  エスケープシーケンスをエスケープ解除する。
  @param result <String|Struct:FailureStruct>
  @returns <String|Struct:FailureStruct>
  */
  private fn unescapeEscape result = (
    local index = findItem this.escapedChars result
    if index > 0 then (
      this.unescapedChars[index]
    )
    else (
      ::FailureStruct()
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #StringStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%StringStruct\n" indent to:out
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
    this.parser = this.expr()
  )
)
