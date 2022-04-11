/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  /* 初期化 */
  local mp = ::MxsPackStruct (getSourceFileName())
  /* 出力先ディレクトリ削除 */
  -- mp.DeleteDirectory @".\Distribution"

  /* コード切り出し */
  local definitionPoolCode = mp.ClipFile @".\definitionPool.ms" 1 2171
  local ParserCombinatorCode = mp.ClipFile @".\ParserCombinator.ms" 1 -1

  local AstNodeCode = mp.ClipFile @".\Model\AstNode.ms" 80 -1
  local CacheCode = mp.ClipFile @".\Model\Cache.ms" 88 -1
  local ContextCode = mp.ClipFile @".\Model\Context.ms" 115 -1
  local ErrorCode = mp.ClipFile @".\Model\Error.ms" 83 -1
  local FailureCode = mp.ClipFile @".\Model\Failure.ms" 82 -1
  local NotCollectCode = mp.ClipFile @".\Model\NotCollect.ms" 95 -1

  local AndCode = mp.ClipFile @".\Parser\And.ms" 680 -1
  local AnyCharCode = mp.ClipFile @".\Parser\AnyChar.ms" 90 -1
  local BoundaryCode = mp.ClipFile @".\Parser\Boundary.ms" 163 -1
  local CharCode = mp.ClipFile @".\Parser\Char.ms" 117 -1
  local ChoiceCode = mp.ClipFile @".\Parser\Choice.ms" 102 -1
  local DelayCode = mp.ClipFile @".\Parser\Delay.ms" 86 -1
  local EOSCode = mp.ClipFile @".\Parser\EOS.ms" 92 -1
  local ExpectCode = mp.ClipFile @".\Parser\Expect.ms" 102 -1
  local IsNotCode = mp.ClipFile @".\Parser\IsNot.ms" 127 -1
  local LookaheadCode = mp.ClipFile @".\Parser\Lookahead.ms" 167 -1
  local ManyCode = mp.ClipFile @".\Parser\Many.ms" 106 -1
  local MapCode = mp.ClipFile @".\Parser\Map.ms" 92 -1
  local MemoizeCode = mp.ClipFile @".\Parser\Memoize.ms" 82 -1
  local OptionCode = mp.ClipFile @".\Parser\Option.ms" 121 -1
  local PartialCode = mp.ClipFile @".\Parser\Partial.ms" 145 -1
  local SequenceCode = mp.ClipFile @".\Parser\Sequence.ms" 131 -1
  local SOSCode = mp.ClipFile @".\Parser\SOS.ms" 92 -1
  local TokenCode = mp.ClipFile @".\Parser\Token.ms" 86 -1

  /* コード置換 */
  local code = mp.ReplaceText definitionPoolCode 2144 28 BoundaryCode
  code = mp.ReplaceText code 2047 24 CharCode
  code = mp.ReplaceText code 1950 25 TokenCode
  code = mp.ReplaceText code 1871 23 SOSCode
  code = mp.ReplaceText code 1789 28 SequenceCode
  code = mp.ReplaceText code 1703 27 PartialCode
  code = mp.ReplaceText code 1619 26 OptionCode
  code = mp.ReplaceText code 1535 27 MemoizeCode
  code = mp.ReplaceText code 1454 23 MapCode
  code = mp.ReplaceText code 1376 24 ManyCode
  code = mp.ReplaceText code 1292 29 LookaheadCode
  code = mp.ReplaceText code 1207 25 IsNotCode
  code = mp.ReplaceText code 1125 26 ExpectCode
  code = mp.ReplaceText code 1045 23 EOSCode
  code = mp.ReplaceText code 966 25 DelayCode
  code = mp.ReplaceText code 884 26 ChoiceCode
  code = mp.ReplaceText code 800 27 AnyCharCode
  code = mp.ReplaceText code 719 23 AndCode
  code = mp.ReplaceText code 627 26 ContextCode
  code = mp.ReplaceText code 517 29 NotCollectCode
  code = mp.ReplaceText code 431 26 FailureCode
  code = mp.ReplaceText code 350 24 ErrorCode
  code = mp.ReplaceText code 271 24 CacheCode
  code = mp.ReplaceText code 190 26 AstNodeCode
  code = mp.ClipText code 64 -1
  code = mp.ReplaceText ParserCombinatorCode 714 27 code

  /* インストールコード追加 */
  code = mp.AppendText code "::ParserCombinatorStruct.Install()\n::ParserCombinatorStruct\n"
  /* インストーラーオプション削除 */
  code = mp.RemoveInstallerOption code
  /* バンドルファイルを保存 */
  -- mp.WriteAllText @".\Distribution\ParserCombinator.bundle.ms" code
  /* 最小化ファイルを保存 */
  code = mp.Minify code
  mp.WriteAllText @".\Distribution\ParserCombinator.min.ms" code
  /* ファイルコピー */
  -- mp.CopyDirectory @".\ParserCombinator.SubDir" @".\Distribution\ParserCombinator.SubDir"
  ok
)
