/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
解析対象の文字列を操作する。
@remarks 改行コードは全て`LF`に変換される。
*/
struct ContextStruct (
  /*- @prop <String> 作成パラメータ1。解析対象の文字列。 */
  public _CP1_,

  /*- @prop <Struct:CacheStruct> */
  private cache,
  /*- @prop <Struct:ErrorStruct> */
  private lastError,
  /*- @prop <Array[<DataPair Start:<Integer> End:<Integer>>]> 行頭と行末の位置の配列。 */
  private lineRanges = #(),
  /*- @prop <StringStream> */
  private ss = StringStream "",

  /*-
  現在の位置がストリームの終端にあるかどうか。
  @returns <BooleanClass>
  */
  public fn EOS = (
    ::eof this.ss
  ),

  /*-
  最後に記録されたエラーを取得する。
  @returns <Struct:ErrorStruct>
  */
  public fn GetLastError = (
    this.lastError
  ),

  /*-
  任意の位置の行数を取得する。
  @param offset <Integer>
  @returns <Integer> 位置が範囲外の場合は`0`を返す。
  */
  public fn GetLineNumber offset = (
    local lineNumber = 0
    for i = 1 to this.lineRanges.Count while lineNumber == 0 do (
      local range = this.lineRanges[i]
      if range.Start <= offset and offset <= range.End do (
        lineNumber = i
      )
    )
    lineNumber
  ),

  /*-
  現在の位置を取得する。
  @returns <Integer>
  */
  public fn GetOffset = (
    ::filePos this.ss
  ),

  /*-
  エラーを記録する。
  @param errorOffset <Integer> エラーが発生した位置。
  @param expected <String> 期待する文字列。
  @returns <OkClass>
  */
  public fn LogError errorOffset expected = (
    if errorOffset > this.lastError.Offset do (
      local offset = this.GetOffset()
      this.Seek errorOffset
      local offsetChar = this.Read 1
      this.Seek offset
      local lineNumber = this.GetLineNumber errorOffset
      local lineText = this.getLineText lineNumber
      this.lastError.Expected = expected
      this.lastError.LineNumber = lineNumber
      this.lastError.LineText = lineText
      this.lastError.Offset = errorOffset
      this.lastError.OffsetChar = offsetChar
    )
    ok
  ),

  /*-
  デバッグ情報をリスナーに出力する。
  @param parserName <String>
  @returns <OkClass>
  */
  public fn PrintDebugInfo parserName startOffset result = (
    local resultText = with printAllElements true result as String
    resultText = ::stringUtility.EscapeBackslash resultText
    if classOf result == String do (
      resultText = "\"" + resultText + "\""
    )
    format "% offset:[%-%] error:(position:% line:% expected:%) result:%\n" \
        parserName startOffset (this.GetOffset()) \
        this.lastError.Offset this.lastError.LineNumber this.lastError.Expected \
        resultText
    ok
  ),

  /*-
  エラー情報をリスナーに出力する。
  @param result <Any>
  @returns <OkClass>
  @remarks 結果が失敗以外の場合は警告として出力する。
  */
  public fn PrintError result = (
    local errorType = undefined
    case classOf result of (
      (::FailureStruct): errorType = "error"
      default: (
        if this.lastError.Offset >= 0 do (
          errorType = "warning"
        )
      )
    )
    if classOf errorType == String do (
      format "[syntax %]at \"%\" in position:% line:%, expected:%, in line:%\n" \
          errorType \
          (::stringUtility.EscapeBackslash this.lastError.OffsetChar) \
          this.lastError.Offset \
          this.lastError.LineNumber \
          this.lastError.Expected \
          (::stringUtility.EscapeBackslash this.lastError.LineText)
    )
    ok
  ),

  /*-
  現在の位置から指定の数の文字を文字列として取得する。
  @returns <String>
  @remarks
  ストリームの終端を超えてしまう場合は現在の位置から終端までの文字列を返す。
  現在の位置がストリームの終端に達している場合は空文字列を返す。
  */
  public fn Read count = (
    ::readChars this.ss count errorAtEOF:false
  ),

  /*-
  パース結果をキャッシュから読み取る。
  @param parser <Struct> メモ化対象のパーサのインスタンス。
  @returns <DataPair Hit:<BooleanClass> Cache:<DataPair End:<Integer> Value:<Any>|UndefinedClass>> キャッシュが存在した場合は`Hit`が`true`になる。
  */
  public fn ReadCache parser = (
    this.cache.Read parser (this.GetOffset())
  ),

  /*-
  位置を設定する。
  @returns <Integer> 設定後の位置。
  @remarks ストリームの終端を超えてしまう場合は終端に設定される。
  */
  public fn Seek offset = (
    ::seek this.ss offset
    this.GetOffset()
  ),

  /*-
  解析対象の文字列を設定する。
  @param input <String>
  @returns <OkClass>
  @remarks 内部状態が初期化される。
  */
  public fn SetStream input = (
    this.initialize()
    this.ss = StringStream (replace_CRLF_with_LF input)
    this.setLineRanges()
    this.Seek 0
    ok
  ),

  /*-
  現在の位置がストリームの先端にあるかどうか。
  @returns <BooleanClass>
  */
  public fn SOS = (
    this.GetOffset() == 0
  ),

  /*-
  パース結果をキャッシュに書き込む。
  @param parser <Struct> メモ化対象のパーサのインスタンス。
  @param start <Integer> 開始位置。
  @param end <Integer> 終了位置。
  @param result <Any> メモ化対象のパーサのパース結果。
  @returns <OkClass>
  */
  public fn WriteCache parser start end result = (
    this.cache.Write parser start end result
  ),

  /*-
  指定した行の文字列を取得する。
  @param lineNumber <Integer>
  @returns <String> 行が範囲外の場合は空文字列を返す。
  @remarks エスケープシーケンスのエスケープ処理は行わない。
  */
  private fn getLineText lineNumber = (
    local lineText = ""
    local lineCount = this.lineRanges.Count
    if lineCount > 0 and 1 <= lineNumber and lineNumber <= lineCount do (
      local offset = this.GetOffset()
      local start = this.lineRanges[lineNumber].Start
      local end = this.lineRanges[lineNumber].End
      this.Seek start
      lineText = this.Read (end - start + 1)
      this.Seek offset
    )
    lineText
  ),

  /*-
  内部状態を初期化する。
  @returns <OkClass>
  */
  private fn initialize = (
    if isStruct this.cache do (
      this.cache.Clear()
    )
    if isStruct this.lastError do (
      this.lastError.Clear()
    )
    this.lineRanges = #()
    this.ss = StringStream ""
    ok
  ),

  /*-
  行の範囲を設定する。
  @returns <OkClass>
  */
  private fn setLineRanges = (
    this.Seek 0
    local lineEnds = #(0)
    while not eof this.ss do (
      if skipToString this.ss "\n" != undefined do (
        append lineEnds (this.GetOffset())
      )
    )
    appendIfUnique lineEnds (this.GetOffset())
    -- EOSの分を最後の位置に足す
    if lineEnds.Count > 0 do (
      lineEnds[lineEnds.Count] += 1
    )
    this.lineRanges = for i = 2 to lineEnds.Count collect (
      DataPair Start:lineEnds[i - 1] End:(lineEnds[i] - 1)
    )
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #ContextStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ContextStruct\n" indent to:out
    format "%  Offset:%\n" indent (this.GetOffset()) to:out
    format "%  cache:\n" indent to:out
    this.cache.Dump indent:(indent + "    ") out:out
    format "%  lastError:\n" indent to:out
    this.lastError.Dump indent:(indent + "    ") out:out
    format "%  lineRanges:%\n" indent this.lineRanges.Count to:out
    local offset = this.GetOffset()
    for i = 1 to this.lineRanges.Count do (
      local start = this.lineRanges[i].Start
      local end = this.lineRanges[i].End

      this.Seek start
      local startChar = this.Read 1
      startChar = ::stringUtility.EscapeBackslash startChar

      this.Seek end
      local endChar = this.Read 1
      endChar = ::stringUtility.EscapeBackslash endChar

      this.Seek start
      local lineText = this.Read (end - start + 1)
      lineText = ::stringUtility.EscapeBackslash lineText

      format "%    [%-%]:Start:\"%\" End:\"%\" Line:\"%\"\n" \
          indent start end startChar endChar lineText to:out
    )
    this.Seek offset
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
    if classOf this._CP1_ == String do (
      this.SetStream this._CP1_
    )
    this.cache = (fileIn "Cache.ms")()
    this.lastError = (fileIn "Error.ms")()
  )
)
