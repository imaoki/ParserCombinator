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
  local context
  local failure = (fileIn (pathUtility.GetFullPath @"..\..\Model\Failure.ms"))()
  local notCollect = (fileIn (pathUtility.GetFullPath @"..\..\Model\NotCollect.ms"))()
  local charDef = fileIn (pathUtility.GetFullPath @"..\Char.ms")
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Model\Context.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Choice.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- パーサ無し
  testObj = testDef #() Debug:false
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- パーサ無し
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- パーサ指定
  testObj = testDef #(charDef "a", charDef "b") Debug:false
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 一致
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致
  context = contextDef "b"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "b"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 大文字と小文字を区別する
  context = contextDef "A"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
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
