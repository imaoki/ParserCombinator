/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
Markdownのパーサ。
*/
struct MarkdownStruct (
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
  private fn document = (
  ),

  /*-
  @returns <Struct>
  */
  private fn block = (
  ),

  /*-
  @returns <Struct>
  */
  private fn containerBlock = (
  ),

  /*-
  @returns <Struct>
  */
  private fn blockQuote = (
  ),

  /*-
  @returns <Struct>
  */
  private fn blockQuoteMarker = (
  ),

  /*-
  @returns <Struct>
  */
  private fn bulletList = (
  ),

  /*-
  @returns <Struct>
  */
  private fn bulletListItem = (
  ),

  /*-
  @returns <Struct>
  */
  private fn orderedList = (
  ),

  /*-
  @returns <Struct>
  */
  private fn orderedListItem = (
  ),

  /*-
  @returns <Struct>
  */
  private fn bulletListMarker = (
  ),

  /*-
  @returns <Struct>
  */
  private fn orderedListMarker = (
  ),

  /*-
  @returns <Struct>
  */
  private fn listItemLeafBlock = (
    this.pc.Choice #(
      this.atxHeading(),
      this.listItemFencedCodeBlock(),
      this.listItemParagraph()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn listItemFencedCodeBlock = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pc.Token "```",
        this.pc.Option (
          this.pc.Sequence #(
            this.pc.Skip (this.pc.Many (this.space())),
            this.backtickInfoString()
          )
        ),
        this.lineEnding(),
        this.pc.Many (
          this.pc.Sequence #(
            this.pc.Token "    ",
            this.line()
          )
        ),
        this.pc.Token "    ",
        this.pc.Token "```",
        this.lineEnding()
      ),
      this.pc.Sequence #(
        this.pc.Token "~~~",
        this.pc.Option (
          this.pc.Sequence #(
            this.pc.Skip (this.pc.Many (this.space())),
            this.tildeInfoString()
          )
        ),
        this.lineEnding(),
        this.pc.Many (
          this.pc.Sequence #(
            this.pc.Token "    ",
            this.line()
          )
        ),
        this.pc.Token "    ",
        this.pc.Token "~~~",
        this.lineEnding()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn listItemParagraph = (
    this.pc.Sequence #(
      this.inlineLine(),
      this.pc.Many (
        this.pc.Sequence #(
          this.pc.Token "    ",
          this.inlineLine()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn leafBlock = (
    this.pc.Choice #(
      this.thematicBreak(),
      this.atxHeading(),
      this.indentedCodeBlock(),
      this.fencedCodeBlock(),
      this.linkReferenceDefinition(),
      this.paragraph(),
      this.blankLines()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn thematicBreak = (
    this.pc.Sequence #(
      this.pc.Choice #(
        this.pc.Token "***",
        this.pc.Token "---",
        this.pc.Token "___"
      ),
      this.pc.Many (this.pc.Char "-"),
      this.pc.Skip (this.pc.Many (this.space())),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading = (
    this.pc.Choice #(
      this.atxHeading1(),
      this.atxHeading2(),
      this.atxHeading3(),
      this.atxHeading4(),
      this.atxHeading5(),
      this.atxHeading6()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading1 = (
    this.pc.Sequence #(
      this.pc.Token "#",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading2 = (
    this.pc.Sequence #(
      this.pc.Token "##",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading3 = (
    this.pc.Sequence #(
      this.pc.Token "###",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading4 = (
    this.pc.Sequence #(
      this.pc.Token "####",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading5 = (
    this.pc.Sequence #(
      this.pc.Token "#####",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxHeading6 = (
    this.pc.Sequence #(
      this.pc.Token "######",
      this.space(),
      this.textualContent(),
      this.atxClosingSequence()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn atxClosingSequence = (
    this.pc.Sequence #(
      this.pc.Option (
        this.pc.Sequence #(
          this.space(),
          this.pc.Many (this.pc.Char "#"),
          this.pc.Many (this.space())
        )
      ),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn indentedCodeBlock = (
    this.pc.Sequence #(
      this.blankLine(),
      this.pc.Many (
        this.pc.Sequence #(
          this.indentedChunk(),
          this.blankLine()
        )
      ) minCount:1
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn indentedChunk = (
    this.pc.Many (
      this.pc.Sequence #(
        this.pc.Token "    ",
        this.pc.Skip (this.pc.Many (this.space())),
        this.nonBlankLine()
      )
    ) minCount:1
  ),

  /*-
  @returns <Struct>
  */
  private fn fencedCodeBlock = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pc.Token "```",
        this.pc.Option (
          this.pc.Sequence #(
            this.pc.Skip (this.pc.Many (this.space())),
            this.backtickInfoString()
          )
        ),
        this.lineEnding(),
        this.pc.Many (this.line()),
        this.pc.Token "```",
        this.lineEnding()
      ),
      this.pc.Sequence #(
        this.pc.Token "~~~",
        this.pc.Option (
          this.pc.Sequence #(
            this.pc.Skip (this.pc.Many (this.space())),
            this.tildeInfoString()
          )
        ),
        this.lineEnding(),
        this.pc.Many (this.line()),
        this.pc.Token "~~~",
        this.lineEnding()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkReferenceDefinition = (
    this.pc.Sequence #(
      this.linkLabel(),
      this.pc.Char ":",
      this.linkDestination(),
      this.Option (
        this.pc.Sequence #(
          this.pc.Skip (this.whitespace()),
          this.linkTitle()
        )
      ),
      this.pc.Skip (this.whitespace()),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn paragraph = (
    this.pc.Many (this.inlineLine()) minCount:1
  ),

  /*-
  @returns <Struct>
  */
  private fn blankLines = (
    this.pc.Many (this.blankLine()) minCount:1
  ),

  /*-
  @returns <Struct>
  */
  private fn blankLine = (
    this.pc.Sequence #(
      this.pc.Many (
        this.pc.Choice #(
          this.space(),
          this.tab()
        )
      ),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn nonBlankLine = (
    this.pc.Sequence #(
      this.nonWhitespaceCharacter(),
      this.pc.Many (this.characterWithoutLinebreak()),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn backtickInfoString = (
    this.pc.Many (
      this.pc.AndAlso #(
        this.pc.IsNot (
          this.pc.Choice #(
            this.pc.Char "`",
            this.space(),
            this.lineEnding()
          )
        ),
        this.pc.AnyChar()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn tildeInfoString = (
    this.pc.Many (
      this.pc.AndAlso #(
        this.pc.IsNot (
          this.pc.Choice #(
            this.space(),
            this.lineEnding()
          )
        ),
        this.pc.AnyChar()
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  -- private fn inline = (
  -- ),

  /*-
  @returns <Struct>
  */
  private fn inlineLine = (
    this.pc.Sequence #(
      this.pc.Many (this.inlineWithoutLineBreak()) minCount:1,
      this.lineBreak()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn inlineWithoutLineBreak = (
    this.pc.Choice #(
      this.codeSpan(),
      this.emphasis(),
      this.strongEmphasis(),
      this.inlineLink(),
      this.fullReferenceLink(),
      this.image(),
      this.textualContent()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn codeSpan = (
    this.pc.Char "`",
      this.pc.Many (
        this.pc.Choice #(
          this.characterWithoutLinebreak(),
          this.pc.Token "\\`"
        )
      ) minCount:1,
    this.pc.Char "`"
  ),

  /*-
  @returns <Struct>
  */
  private fn emphasis = (
    this.pc.Char "*",
      this.pc.Many (
        this.pc.Choice #(
          this.characterWithoutLinebreak(),
          this.pc.Token "\\*"
        )
      ) minCount:1,
    this.pc.Char "*"
  ),

  /*-
  @returns <Struct>
  */
  private fn strongEmphasis = (
    this.pc.Sequence #(
      this.pc.Char "**",
      this.pc.Many (
        this.pc.Choice #(
          this.characterWithoutLinebreak(),
          this.pc.Token "\\*\\*"
        )
      ) minCount:1,
      this.pc.Char "**"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn inlineLink = (
    this.pc.Sequence #(
      this.linkText(),
      this.linkComponent()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn fullReferenceLink = (
    this.pc.Sequence #(
      this.linkText(),
      this.linkLabel()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkText = (
    this.pc.Sequence #(
      this.pc.Char "[",
      this.textualContent(),
      this.pc.Char "]"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkLabel = (
    this.pc.Sequence #(
      this.pc.Char "[",
      this.pc.Many (this.nonWhitespaceCharacter()) minCount:1,
      this.pc.Char "]"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn image = (
    this.pc.Sequence #(
      this.imageDescription(),
      this.linkComponent()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn imageDescription = (
    this.pc.Sequence #(
      this.pc.Token "![",
      this.textualContent(),
      this.pc.Char "]"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkComponent = (
    this.pc.Sequence #(
      this.pc.Char "(",
      this.pc.Skip (this.whitespace()),
      this.pc.Option (this.linkDestination()),
      this.pc.Option (
        this.pc.Sequence #(
          this.pc.Skip (this.whitespace()),
          this.pc.linkTitle()
        )
      ),
      this.pc.Skip (this.whitespace()),
      this.pc.Char ")"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkDestination = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pc.Char "<",
        this.pc.Many (
          this.pc.Choice #(
            this.pc.AndAlso (
              this.pc.IsNot (
                this.pc.Choice #(
                  this.lineEnding(),
                  this.pc.Char "<",
                  this.pc.Char ">"
                )
              ),
              this.pc.AnyChar()
            ),
            this.pc.Token "\\<",
            this.pc.Token "\\>"
          )
        ),
        this.pc.Char ">"
      ),
      this.pc.Many (
        this.pc.Choice #(
          this.pc.AndAlso #(
            this.pc.IsNot (
              this.pc.Choice #(
                this.asciiControlCharacter(),
                this.space(),
                this.pc.Char "(",
                this.pc.Char ")"
              )
            ),
            this.pc.AnyChar()
          ),
          this.backslashEscape()
        )
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn linkTitle = (
    this.pc.Choice #(
      this.pc.Sequence #(
        this.pc.Char "\"",
        this.pc.Many (
          this.pc.Choice #(
            this.pc.AndAlso #(
              this.pc.IsNot (this.pc.Char "\""),
              this.pc.AnyChar()
            ),
            this.pc.Token "\\\""
          )
        ),
        this.pc.Char "\""
      ),
      this.pc.Sequence #(
        this.pc.Char "'",
        this.pc.Many (
          this.pc.Choice #(
            this.pc.AndAlso #(
              this.pc.IsNot (this.pc.Char "'"),
              this.pc.AnyChar()
            ),
            this.pc.Token "\\'"
          )
        ),
        this.pc.Char "'"
      ),
      this.pc.Sequence #(
        this.pc.Char "(",
        this.pc.Many (
          this.pc.Choice #(
            this.pc.AndAlso #(
              this.pc.IsNot (this.pc.Char "()"),
              this.pc.AnyChar()
            ),
            this.pc.Token "\\(",
            this.pc.Token "\\)"
          )
        ),
        this.pc.Char ")"
      )
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn line = (
    this.pc.Sequence #(
      this.pc.Many (
        this.pc.AndAlso #(
          this.pc.IsNot (this.lineEnding()),
          this.pc.AnyChar()
        )
      ),
      this.lineEnding()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn lineEnding = (
    this.pc.Choice #(
      this.newline(),
      this.carriageReturn(),
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn textualContent = (
    this.pc.Many (this.characterWithoutLinebreak())
  ),

  /*-
  @returns <Struct>
  */
  private fn characterWithoutLinebreak = (
    this.pc.AndAlso #(
      this.pc.IsNot (
        this.pc.Choice #(
          this.newline(),
          this.carriageReturn(),
        )
      ),
      this.pc.AnyChar()
    )
  ),

  /*-
  @returns <Struct>
  */
  -- private fn unicodeWhitespace = (
  -- ),

  /*-
  @returns <Struct>
  */
  -- private fn unicodeWhitespaceCharacter = (
  -- ),

  /*-
  @returns <Struct>
  */
  private fn whitespace = (
    this.pc.Many (this.whitespaceCharacter()) minCount:1
  ),

  /*-
  @returns <Struct>
  */
  private fn nonWhitespaceCharacter = (
    this.pc.AndAlso #(
      this.pc.IsNot (this.whitespaceCharacter()),
      this.pc.AnyChar()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn whitespaceCharacter = (
    this.pc.Choice #(
      this.newline(),
      this.carriageReturn(),
      this.space(),
      this.tab(),
      this.verticalTabulation(),
      this.formFeed()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn newline = (
    this.pc.Char "\x000A"
  ),

  /*-
  @returns <Struct>
  */
  private fn carriageReturn = (
    this.pc.Char "\x000D"
  ),

  /*-
  @returns <Struct>
  */
  private fn space = (
    this.pc.Char "\x0020"
  ),

  /*-
  @returns <Struct>
  */
  private fn tab = (
    this.pc.Char "\x0009"
  ),

  /*-
  @returns <Struct>
  */
  private fn verticalTabulation = (
    this.pc.Char "\x000B"
  ),

  /*-
  @returns <Struct>
  */
  private fn formFeed = (
    this.pc.Char "\x000C"
  ),

  /*-
  @returns <Struct>
  */
  private fn lineBreak = (
    this.pc.Choice #(
      this.hardLineBreak(),
      this.softLineBreak()
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn hardLineBreak = (
    this.pc.Sequence #(
      this.pc.Choice #(
        this.pc.Token "  ",
        this.pc.Char "\\"
      ),
      this.pc.Char "\n"
    )
  ),

  /*-
  @returns <Struct>
  */
  private fn softLineBreak = (
    this.pc.Char "\n"
  ),

  /*-
  @returns <Struct>
  */
  public fn backslashEscape = (
    this.pc.Choice #(
      this.pc.Char "\\!",
      this.pc.Char "\\\"",
      this.pc.Char "\\#",
      this.pc.Char "\\$",
      this.pc.Char "\\%",
      this.pc.Char "\\&",
      this.pc.Char "\\'",
      this.pc.Char "\\(",
      this.pc.Char "\\)",
      this.pc.Char "\\*",
      this.pc.Char "\\+",
      this.pc.Char "\\,",
      this.pc.Char "\\-",
      this.pc.Char "\\.",
      this.pc.Char "\\/",
      this.pc.Char "\\:",
      this.pc.Char "\\;",
      this.pc.Char "\\<",
      this.pc.Char "\\=",
      this.pc.Char "\\>",
      this.pc.Char "\\?",
      this.pc.Char "\\@",
      this.pc.Char "\\[",
      this.pc.Char "\\\\",
      this.pc.Char "\\]",
      this.pc.Char "\\^",
      this.pc.Char "\\_",
      this.pc.Char "\\`",
      this.pc.Char "\\{",
      this.pc.Char "\\|",
      this.pc.Char "\\}",
      this.pc.Char "\\~"
    )
  ),

  /*-
  @returns <Struct>
  */
  public fn asciiControlCharacter = (
    this.pc.Choice #(
      this.pc.Char "\x0000",
      this.pc.Char "\x0001",
      this.pc.Char "\x0002",
      this.pc.Char "\x0003",
      this.pc.Char "\x0004",
      this.pc.Char "\x0005",
      this.pc.Char "\x0006",
      this.pc.Char "\x0007",
      this.pc.Char "\x0008",
      this.pc.Char "\x0009",
      this.pc.Char "\x000A",
      this.pc.Char "\x000B",
      this.pc.Char "\x000C",
      this.pc.Char "\x000D",
      this.pc.Char "\x000E",
      this.pc.Char "\x000F",
      this.pc.Char "\x0010",
      this.pc.Char "\x0011",
      this.pc.Char "\x0012",
      this.pc.Char "\x0013",
      this.pc.Char "\x0014",
      this.pc.Char "\x0015",
      this.pc.Char "\x0016",
      this.pc.Char "\x0017",
      this.pc.Char "\x0018",
      this.pc.Char "\x0019",
      this.pc.Char "\x001A",
      this.pc.Char "\x001B",
      this.pc.Char "\x001C",
      this.pc.Char "\x001D",
      this.pc.Char "\x001E",
      this.pc.Char "\x001F",
      this.pc.Char "\x007F"
    )
  ),

  /*-
  @returns <Struct>
  */
  public fn asciiPunctuationCharacter = (
    this.pc.Choice #(
      this.pc.Char "!",
      this.pc.Char "\"",
      this.pc.Char "#",
      this.pc.Char "$",
      this.pc.Char "%",
      this.pc.Char "&",
      this.pc.Char "'",
      this.pc.Char "(",
      this.pc.Char ")",
      this.pc.Char "*",
      this.pc.Char "+",
      this.pc.Char ",",
      this.pc.Char "-",
      this.pc.Char ".",
      this.pc.Char "/",
      this.pc.Char ":",
      this.pc.Char ";",
      this.pc.Char "<",
      this.pc.Char "=",
      this.pc.Char ">",
      this.pc.Char "?",
      this.pc.Char "@",
      this.pc.Char "[",
      this.pc.Char "\\",
      this.pc.Char "]",
      this.pc.Char "^",
      this.pc.Char "_",
      this.pc.Char "`",
      this.pc.Char "{",
      this.pc.Char "|",
      this.pc.Char "}",
      this.pc.Char "~"
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #MarkdownStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MarkdownStruct\n" indent to:out
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
    this.pc = (fileIn (pathUtility.GetFullPath @"..\..\ParserCombinator.ms"))()
    this.parser = this.document()
  )
)
