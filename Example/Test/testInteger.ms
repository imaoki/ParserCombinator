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
  local failure = (fileIn (pathUtility.GetFullPath @"..\..\Model\Failure.ms"))()
  local notCollect = (fileIn (pathUtility.GetFullPath @"..\..\Model\NotCollect.ms"))()

  testDef = fileIn (pathUtility.GetFullPath @"..\Integer.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- true
  actual = ::TestValueStruct (testObj.Parse "true")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 0
  actual = ::TestValueStruct (testObj.Parse "0")
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 10
  actual = ::TestValueStruct (testObj.Parse "10")
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- -222
  actual = ::TestValueStruct (testObj.Parse "-222")
  expected = ::TestValueStruct -222
  assert (actual.Equals expected == true)
  -- +3456789
  actual = ::TestValueStruct (testObj.Parse "+3456789")
  expected = ::TestValueStruct 3456789
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
