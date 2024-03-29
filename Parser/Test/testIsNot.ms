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
  local charDef = ::parserCombinatorDefinitionPool[@"Parser\Char.ms"]
  local contextDef = ::parserCombinatorDefinitionPool[@"Model\Context.ms"]

  testDef = ::parserCombinatorDefinitionPool[@"Parser\IsNot.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コードの場合は`::readChars`の結果が返る
  testObj = testDef (charDef "a") Debug:false
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 一致するので失敗
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致しないので成功
  context = contextDef "A"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致しないので成功
  context = contextDef "hoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
