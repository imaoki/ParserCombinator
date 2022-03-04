/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
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
  local failure = (fileIn (pathUtility.GetFullPath @"..\..\Model\Failure.ms"))()
  local notCollect = (fileIn (pathUtility.GetFullPath @"..\..\Model\NotCollect.ms"))()

  testDef = fileIn (pathUtility.GetFullPath @"..\Memoization.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* ParseNotMemo */
  -- 空コード
  actual = ::TestValueStruct (testObj.ParseNotMemo "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 一致
  actual = ::TestValueStruct (testObj.ParseNotMemo "((((((((1))))))))")
  -- actual.Dump()
  expected = ::TestValueStruct #("(", #("(", #("(", #("(", #("(", #("(", #("(", #("(", "1", ")"), ")"), ")"), ")"), ")"), ")"), ")"), ")")
  assert (actual.Equals expected == true)

  sw.Stop()
  format "[end % not memo]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  sw.Restart()

  /* ParseMemoized */
  -- 空コード
  actual = ::TestValueStruct (testObj.ParseMemoized "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 一致
  actual = ::TestValueStruct (testObj.ParseMemoized "((((((((1))))))))")
  -- actual.Dump()
  expected = ::TestValueStruct #("(", #("(", #("(", #("(", #("(", #("(", #("(", #("(", "1", ")"), ")"), ")"), ")"), ")"), ")"), ")"), ")")
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end % memoized]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
