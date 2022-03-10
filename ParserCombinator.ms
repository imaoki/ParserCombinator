/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
fileIn @"definitionPool.ms"
/*-
再帰下降構文解析のためのパーサコンビネータ。
*/
struct ParserCombinatorStruct (
  /*- @prop <StructDef:AndStruct> */
  private andDef,
  /*- @prop <StructDef:AnyCharStruct> */
  private anyCharDef,
  /*- @prop <StructDef:BoundaryStruct> */
  private boundaryDef,
  /*- @prop <StructDef:CharStruct> */
  private charDef,
  /*- @prop <StructDef:ChoiceStruct> */
  private choiceDef,
  /*- @prop <StructDef:ContextStruct> */
  private contextDef,
  /*- @prop <StructDef:DelayStruct> */
  private delayDef,
  /*- @prop <StructDef:EOSStruct> */
  private eosDef,
  /*- @prop <StructDef:ExpectStruct> */
  private expectDef,
  /*- @prop <StructDef:IsNotStruct> */
  private isNotDef,
  /*- @prop <StructDef:LookaheadStruct> */
  private lookaheadDef,
  /*- @prop <StructDef:ManyStruct> */
  private manyDef,
  /*- @prop <StructDef:MapStruct> */
  private mapDef,
  /*- @prop <StructDef:MemoizeStruct> */
  private memoizeDef,
  /*- @prop <StructDef:OptionStruct> */
  private optionDef,
  /*- @prop <StructDef:PartialStruct> */
  private partialDef,
  /*- @prop <StructDef:SequenceStruct> */
  private sequenceDef,
  /*- @prop <StructDef:SOSStruct> */
  private sosDef,
  /*- @prop <StructDef:TokenStruct> */
  private tokenDef,

  /*
  public fn Alphabet debug:false = (),
  public fn AndAlso parsers debug:false = (),
  public fn AnyChar debug:false = (),
  public fn Boundary debug:false = (),
  public fn Char pattern except:false debug:false = (),
  public fn Choice parsers debug:false = (),
  public fn Context input = (),
  public fn Delay callback debug:false = (),
  public fn Diff parserA parserB debug:false = (),
  public fn Digit debug:false = (),
  public fn EOS debug:false = (),
  public fn Expect parser expected:"" debug:false = (),
  public fn Flatten parser depth:-1 debug:false = (),
  public fn Install = (),
  public fn IsNot parser debug:false = (),
  public fn ItemAt parser index debug:false = (),
  public fn Join parser separator:"" debug:false = (),
  public fn List parser separator debug:false = (),
  public fn Lookahead parsers debug:false = (),
  public fn LowerAlphabet debug:false = (),
  public fn Many parser minCount:0 maxCount:2147483647 debug:false = (),
  public fn Map parser callback debug:false = (),
  public fn Memo parser debug:false = (),
  public fn Option parser debug:false = (),
  public fn Partial callback callbackParameter parser debug:false = (),
  public fn Sequence parsers debug:false = (),
  public fn Skip parser debug:false = (),
  public fn SOS debug:false = (),
  public fn Token pattern ignoreCase:true debug:false = (),
  public fn Uninstall = (),
  public fn UpperAlphabet debug:false = (),

  private fn arrayItemAt index result = (),
  private fn asNotCollect result = (),
  private fn cons result = (),
  private fn flattenArray depth result asString:false d:1 = (),
  private fn joinArray separator result = (),
  */

  /*-
  アルファベットに一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:ChoiceStruct>
  */
  public fn Alphabet debug:false = (
    this.Choice #(
      this.LowerAlphabet debug:debug,
      this.UpperAlphabet debug:debug
    ) debug:debug
  ),

  /*-
  与えられたパーサの内、最後のパーサの結果を返すパーサ。
  @param parsers <Array[<Struct>]>
  @param debug: <BooleanClass>
  @returns <Struct:AndStruct>
  @remarks
  最後以外のパーサが成功している間は解析対象の文字列を消費しない。
  もし最後以外のパーサが失敗するとその時点でパース失敗となる。
  */
  public fn AndAlso parsers debug:false = (
    this.andDef parsers Debug:debug
  ),

  /*-
  どのような一文字にも一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:AnyCharStruct>
  */
  public fn AnyChar debug:false = (
    this.anyCharDef Debug:debug
  ),

  /*-
  ワード境界に一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:BoundaryStruct>
  @remarks 現在位置の前後において一方が正規表現の`\w`（`[a-zA-Z_0-9]`）、もう一方が`\W`に一致する場合をワード境界とみなす。
  */
  public fn Boundary debug:false = (
    this.boundaryDef Debug:debug
  ),

  /*-
  入力文字列に含まれる一文字に一致するパーサ。
  @param pattern <String>
  @param except: <BooleanClass> 一致すると失敗にする場合は`true`、成功にする場合は`false`。既定値は`false`。
  @param debug: <BooleanClass>
  @returns <Struct:CharStruct>
  @remarks 大文字と小文字を区別する。
  */
  public fn Char pattern except:false debug:false = (
    this.charDef pattern except Debug:debug
  ),

  /*-
  与えられたパーサを順に試して最初に成功した結果を返すパーサ。
  @param parsers <Array[<Struct>]>
  @param debug: <BooleanClass>
  @returns <Struct:ChoiceStruct>
  */
  public fn Choice parsers debug:false = (
    this.choiceDef parsers Debug:debug
  ),

  /*-
  解析対象の文字列を操作するためのオブジェクトを生成する。
  @param input <String> 解析対象の文字列。
  @returns <Struct:ContextStruct>
  */
  public fn Context input = (
    if classOf input != String do (
      input = input as String
    )
    this.contextDef input
  ),

  /*-
  パーサを遅延評価するパーサ。
  @param callback <MAXScriptFunction> パーサインスタンスを返す関数値。
  @param debug: <BooleanClass>
  @returns <Struct:DelayStruct>
  */
  public fn Delay callback debug:false = (
    this.delayDef callback Debug:debug
  ),

  /*-
  パーサAに一致するもののうちパーサBに一致するものを除外するパーサ。
  @param parserA <Struct>
  @param parserB <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:PartialStruct>
  */
  public fn Diff parserA parserB debug:false = (
    this.ItemAt (
      this.Sequence #(
        this.IsNot parserB debug:debug,
        parserA
      ) debug:debug
    ) -1 debug:debug
  ),

  /*-
  数字に一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:CharStruct>
  */
  public fn Digit debug:false = (
    this.Char "0123456789" debug:debug
  ),

  /*-
  解析対象の文字列の終端に一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:EOSStruct>
  */
  public fn EOS debug:false = (
    this.eosDef Debug:debug
  ),

  /*-
  成功を期待するパーサが失敗した場合にエラーを記録するパーサ。
  @param parser <Struct>
  @param expected: <String> 期待する構文規則。既定値は`""`。
  @param debug: <BooleanClass>
  @returns <Struct:ExpectStruct>
  @remarks `expected`に渡す文字列のエスケープシーケンスは予めエスケープすること。
  */
  public fn Expect parser expected:"" debug:false = (
    this.expectDef parser expected Debug:debug
  ),

  /*-
  与えられたパーサが返す配列を一次元配列にするパーサ。
  @param parser <Struct>
  @param depth: <Integer> 統合する次元の深さ。`-1`で全ての次元を統合する。既定値は`-1`。
  @param debug: <BooleanClass>
  @returns <Struct:PartialStruct>
  */
  public fn Flatten parser depth:-1 debug:false = (
    this.Partial this.flattenArray depth parser debug:debug
  ),

  /*-
  インストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Install = (
    ::AstNodeStruct = ::parserCombinatorDefinitionPool[@"Model\AstNode.ms"]
    ::FailureStruct = ::parserCombinatorDefinitionPool[@"Model\Failure.ms"]
    ::NotCollectStruct = ::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"]
    if isProperty ::startupLoader #RegisterFile do (
      ::startupLoader.RegisterFile (getSourceFileName()) installer:true
    )
    format "[install]::ParserCombinatorStruct\n"
    ok
  ),

  /*-
  入力したパーサが成功すれば失敗し、失敗すれば成功するパーサ。
  @param parser <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:IsNotStruct>
  @remarks 解析対象の文字列を消費しない。
  */
  public fn IsNot parser debug:false = (
    this.isNotDef parser Debug:debug
  ),

  /*-
  与えられたパーサが配列を返す時、指定したインデックスの要素を返すパーサ。
  @param parser <Struct>
  @param index <Integer> `-1`を指定した場合は最後の要素を取得する。
  @param debug: <BooleanClass>
  @returns <Struct:PartialStruct>
  */
  public fn ItemAt parser index debug:false = (
    this.Partial this.arrayItemAt index parser debug:debug
  ),

  /*-
  与えられたパーサが返す配列の要素を全て文字列として連結するパーサ。
  @param parser <Struct>
  @param separator: <String> 区切り文字。
  @param debug: <BooleanClass>
  @returns <Struct:PartialStruct>
  */
  public fn Join parser separator:"" debug:false = (
    this.Partial this.joinArray separator parser debug:debug
  ),

  /*-
  配列等の区切り文字で区切られた文字列を解析するパーサ。
  @param parser <Struct>
  @param separator <Struct> 区切り文字のパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:MapStruct>
  @remarks *`separator`に`Skip`を使用すると失敗するので注意すること。*
  */
  public fn List parser separator debug:false = (
    this.Map (
      this.Sequence #(
        parser,
        this.Many (
          this.ItemAt (
            this.Sequence #(separator, parser) debug:debug
          ) 2 debug:debug
        ) debug:debug
      ) debug:debug
    ) this.cons debug:debug
  ),

  /*-
  先読みパーサ。
  @param parsers <Array[<Struct>]>
  @param debug: <BooleanClass>
  @returns <Struct:LookaheadStruct>
  @remarks
  2番目以降のパーサが成功した時、1番目のパーサの結果を返す。
  解析対象の文字列は1番目のパーサ分だけ消費する。
  失敗した場合は解析対象の文字列を消費しない。
  */
  public fn Lookahead parsers debug:false = (
    this.lookaheadDef parsers Debug:debug
  ),

  /*-
  小文字のアルファベットに一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:CharStruct>
  */
  public fn LowerAlphabet debug:false = (
    this.Char "abcdefghijklmnopqrstuvwxyz" debug:debug
  ),

  /*-
  与えられたパーサを失敗するまで繰り返し、結果を配列として返すパーサ。
  @param parser <Struct>
  @param minCount: <Integer> 最小繰り返し回数。既定値は`0`。
  @param maxCount: <Integer> 最大繰り返し回数。既定値は`2147483647`。
  @param debug: <BooleanClass>
  @returns <Struct:ManyStruct>
  */
  public fn Many parser minCount:0 maxCount:2147483647 debug:false = (
    this.manyDef parser minCount maxCount Debug:debug
  ),

  /*-
  与えられたパーサの結果を加工するパーサ。
  @param parser <Struct>
  @param callback <MAXScriptFunction> パーサの結果を引数に取る加工用の関数。
  @param debug: <BooleanClass>
  @returns <Struct:MapStruct>
  */
  public fn Map parser callback debug:false = (
    this.mapDef parser callback Debug:debug
  ),

  /*-
  パーサをメモ化する。
  @param parser <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:MemoizeStruct>
  @remarks `And`、`Choice`、`Lookahead`等のバックトラックが発生するパーサに使用すると効果が大きい。
  */
  public fn Memo parser debug:false = (
    this.memoizeDef parser Debug:debug
  ),

  /*-
  与えられたパーサが失敗した場合でも`NotCollectStruct`を返す（成功となる）パーサ。
  @param parser <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:OptionStruct>
  */
  public fn Option parser debug:false = (
    this.optionDef parser Debug:debug
  ),

  /*-
  パース結果を加工する関数を部分適用するためのパーサ。
  @param callback <MAXScriptFunction> 加工用関数。
  @param callbackParameter <Any> 加工用関数の引数。
  @param parser <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:PartialStruct>
  @remarks 加工用関数は第一引数に加工用のパラメータ、第二引数にパース結果を取ること。
  */
  public fn Partial callback callbackParameter parser debug:false = (
    this.partialDef callback callbackParameter parser Debug:debug
  ),

  /*-
  与えられたパーサの結果を配列として返すパーサ。
  @param parsers <Array[<Struct>]>
  @param debug: <BooleanClass>
  @returns <Struct:SequenceStruct>
  @remarks パーサが一つでも失敗した場合はこのパーサも失敗する。
  */
  public fn Sequence parsers debug:false = (
    this.sequenceDef parsers Debug:debug
  ),

  /*-
  与えられたパーサが失敗した場合は失敗し、成功した場合は`NotCollectStruct`を返すパーサ。
  @param parser <Struct>
  @param debug: <BooleanClass>
  @returns <Struct:MapStruct>
  */
  public fn Skip parser debug:false = (
    this.Map parser this.asNotCollect debug:debug
  ),

  /*-
  解析対象の文字列の先端に一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:SOSStruct>
  */
  public fn SOS debug:false = (
    this.sosDef Debug:debug
  ),

  /*-
  入力文字列に一致するパーサ。
  @param pattern <String>
  @param ignoreCase: <BooleanClass> 大文字と小文字を区別しない場合は`true`、区別する場合は`false`。既定値は`true`。
  @param debug: <BooleanClass>
  @returns <Struct:TokenStruct>
  */
  public fn Token pattern ignoreCase:true debug:false = (
    this.tokenDef pattern ignoreCase Debug:debug
  ),

  /*-
  アンインストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Uninstall = (
    if isProperty ::startupLoader #UnregisterFile do (
      ::startupLoader.UnregisterFile (getSourceFileName())
    )
    format "[uninstall]::ParserCombinatorStruct\n"
    ok
  ),

  /*-
  大文字のアルファベットに一致するパーサ。
  @param debug: <BooleanClass>
  @returns <Struct:CharStruct>
  */
  public fn UpperAlphabet debug:false = (
    this.Char "ABCDEFGHIJKLMNOPQRSTUVWXYZ" debug:debug
  ),

  /*-
  配列から指定したインデックスの要素を取得する。
  @param index <Integer> `-1`を指定した場合は最後の要素を取得する。
  @param result <Array[<Any>]|Struct:FailureStruct>
  @returns <Any|Struct:FailureStruct> `result`が空配列または配列以外の場合、および`index`が範囲外の場合は`FailureStruct`を返す。
  */
  private fn arrayItemAt index result = (
    if classOf result == Array and result.Count > 0 \
        and (index < 0 or (1 <= index and index <= result.Count)) then (
      if index < 0 then (
        result[result.Count]
      )
      else (
        result[index]
      )
    )
    else (
      ::FailureStruct()
    )
  ),

  /*-
  結果を常に`NotCollectStruct`にする。
  @param result <Any>
  @returns <Struct:NotCollectStruct>
  */
  private fn asNotCollect result = (
    ::NotCollectStruct()
  ),

  /*-
  配列の2番目の要素を展開する。
  @param result <Array[<Any>]|Struct:FailureStruct>
  @returns <Array[<Any>]|Struct:FailureStruct>
  */
  private fn cons result = (
    if classOf result == Array \
        and result.Count == 2 \
        and classOf result[2] == Array then (
      local results = #(result[1])
      for i = 1 to result[2].Count do (
        append results result[2][i]
      )
      results
    )
    else (
      result
    )
  ),

  /*-
  多次元配列を一次元配列にする。
  @param depth <Integer> 統合する次元の深さ。`-1`で全ての次元を統合する。
  @param result <Array[<Any>]>
  @param asString: <BooleanClass> 要素を文字列化する場合は`true`、そのままにする場合は`false`。既定値は`false`。
  @param d: <Integer> 現在の深さ。
  @returns <Array[<Any>]>
  @remarks `result`が配列以外の場合は何もしない。
  */
  private fn flattenArray depth result asString:false d:1 = (
    if classOf result == Array then (
      local flattenedResult = #()
      for v in result do (
        if classOf v == Array then (
          if depth < 0 or (0 < depth and d <= depth) then (
            ::join flattenedResult (
              this.flattenArray depth v asString:asString d:(d + 1)
            )
          )
          else (
            append flattenedResult v
          )
        )
        else (
          if asString and classOf v != String then (
            append flattenedResult (v as String)
          )
          else (
            append flattenedResult v
          )
        )
      )
      flattenedResult
    )
    else (
      result
    )
  ),

  /*-
  配列の要素を全て文字列として連結する。
  @param separator <String> 区切り文字。
  @param result <Array[<Any>]>
  @returns <String>
  @remarks `result`が配列以外の場合は何もしない。
  */
  private fn joinArray separator result = (
    if classOf result == Array then (
      result = this.flattenArray -1 result asString:true
      ::std.StringUtility.Join result separator:separator
    )
    else (
      result
    )
  ),

  /*- @prop <String> バージョン番号。メジャー、マイナー、パッチの順。 */
  private version = "1.0.0",

  /*- @returns <Name> */
  public fn StructName = #ParserCombinatorStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%ParserCombinatorStruct\n" indent to:out
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

  /*-
  @returns <String>
  */
  public fn GetVersion = (
    this.version
  ),

  on Create do (
    this.andDef = ::parserCombinatorDefinitionPool[@"Parser\And.ms"]
    this.anyCharDef = ::parserCombinatorDefinitionPool[@"Parser\AnyChar.ms"]
    this.boundaryDef = ::parserCombinatorDefinitionPool[@"Parser\Boundary.ms"]
    this.charDef = ::parserCombinatorDefinitionPool[@"Parser\Char.ms"]
    this.choiceDef = ::parserCombinatorDefinitionPool[@"Parser\Choice.ms"]
    this.contextDef = ::parserCombinatorDefinitionPool[@"Model\Context.ms"]
    this.delayDef = ::parserCombinatorDefinitionPool[@"Parser\Delay.ms"]
    this.eosDef = ::parserCombinatorDefinitionPool[@"Parser\Eos.ms"]
    this.expectDef = ::parserCombinatorDefinitionPool[@"Parser\Expect.ms"]
    this.isNotDef = ::parserCombinatorDefinitionPool[@"Parser\IsNot.ms"]
    this.lookaheadDef = ::parserCombinatorDefinitionPool[@"Parser\Lookahead.ms"]
    this.manyDef = ::parserCombinatorDefinitionPool[@"Parser\Many.ms"]
    this.mapDef = ::parserCombinatorDefinitionPool[@"Parser\Map.ms"]
    this.memoizeDef = ::parserCombinatorDefinitionPool[@"Parser\Memoize.ms"]
    this.optionDef = ::parserCombinatorDefinitionPool[@"Parser\Option.ms"]
    this.partialDef = ::parserCombinatorDefinitionPool[@"Parser\Partial.ms"]
    this.sequenceDef = ::parserCombinatorDefinitionPool[@"Parser\Sequence.ms"]
    this.sosDef = ::parserCombinatorDefinitionPool[@"Parser\SOS.ms"]
    this.tokenDef = ::parserCombinatorDefinitionPool[@"Parser\Token.ms"]
  )
)
