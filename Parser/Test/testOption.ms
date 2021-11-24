/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  local context
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()
  local charDef = fileIn (pathUtility.GetFullPath @"..\Char.ms")
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Context.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Option.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  testObj = testDef (charDef "a") Debug:false
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
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
  -- 最初の一文字に一致
  context = contextDef "aa"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致しない
  context = contextDef "b"
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
