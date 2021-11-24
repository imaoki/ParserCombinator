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
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()

  testDef = fileIn (pathUtility.GetFullPath @"..\Boolean.ms")
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
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- True
  actual = ::TestValueStruct (testObj.Parse "TRUE")
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- false
  actual = ::TestValueStruct (testObj.Parse "false")
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 失敗
  actual = ::TestValueStruct (testObj.Parse "1")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
