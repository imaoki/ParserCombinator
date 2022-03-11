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
  local contextDef = ::parserCombinatorDefinitionPool[@"Model\Context.ms"]
  local optionDef = ::parserCombinatorDefinitionPool[@"Parser\Option.ms"]

  testDef = ::parserCombinatorDefinitionPool[@"Parser\Many.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  testObj = testDef (charDef "a") Debug:false
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 1回の繰り返し
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 2回の繰り返し
  context = contextDef "aa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 2回の繰り返し
  context = contextDef "aab"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 最小繰り返し回数を指定
  testObj = testDef (charDef "a") 1 Debug:false
  -- 0回の繰り返し
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 1回の繰り返し
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 2回の繰り返し
  context = contextDef "aa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 2回の繰り返し
  context = contextDef "aab"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 最小および最大繰り返し回数を指定
  testObj = testDef (charDef "a") 1 2 Debug:false
  -- 0回の繰り返し
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 1回の繰り返し
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 2回の繰り返し
  context = contextDef "aa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 3回の繰り返し
  context = contextDef "aaa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 制限なし
  testObj = testDef (charDef "a") Debug:false
  -- 10回の繰り返し
  context = contextDef "aaaaaaaaaa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("a", "a", "a", "a", "a", "a", "a", "a", "a", "a")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- 無限ループ
  testObj = testDef (optionDef (anyCharDef())) Debug:false
  -- 終端で終わるかどうか
  context = contextDef "foobar\nhogepiyo\n"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("f", "o", "o", "b", "a", "r", "\n", "h", "o", "g", "e", "p", "i", "y", "o", "\n")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 16
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
