/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::std.PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  local context
  local failure = (::parserCombinatorDefinitionPool[@"Model\Failure.ms"])()
  local notCollect = (::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"])()
  local anyCharDef = ::parserCombinatorDefinitionPool[@"Parser\AnyChar.ms"]
  local charDef = ::parserCombinatorDefinitionPool[@"Parser\Char.ms"]
  local choiceDef = ::parserCombinatorDefinitionPool[@"Parser\Choice.ms"]
  local contextDef = ::parserCombinatorDefinitionPool[@"Model\Context.ms"]
  local isNotDef = ::parserCombinatorDefinitionPool[@"Parser\IsNot.ms"]
  local manyDef = ::parserCombinatorDefinitionPool[@"Parser\Many.ms"]
  local tokenDef = ::parserCombinatorDefinitionPool[@"Parser\Token.ms"]

  testDef = ::parserCombinatorDefinitionPool[@"Parser\And.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- パーサ無し
  testObj = testDef #() Debug:false
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- パーサ設定
  testObj = testDef #(
    (choiceDef #((tokenDef "foo"), (tokenDef "bar"))),
    (anyCharDef())
  ) Debug:false
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致する
  context = contextDef "foo"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "f"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致する
  context = contextDef "bar"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "b"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致しない
  context = contextDef "hoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- パーサ設定
  testObj = manyDef (
    testDef #(
      (isNotDef (charDef "d")),
      (anyCharDef())
    ) Debug:false
  )
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致する
  context = contextDef "abcd"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "b", "c")
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
