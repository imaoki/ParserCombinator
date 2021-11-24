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

  testDef = fileIn (pathUtility.GetFullPath @"..\Number.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- `+`で開始
  actual = ::TestValueStruct (testObj.Parse "+1")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- `-`のみ
  actual = ::TestValueStruct (testObj.Parse "-")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- `-`で開始
  actual = ::TestValueStruct (testObj.Parse "-1")
  expected = ::TestValueStruct -1
  assert (actual.Equals expected == true)
  -- 整数
  actual = ::TestValueStruct (testObj.Parse "12")
  expected = ::TestValueStruct 12
  assert (actual.Equals expected == true)
  -- 有理数
  actual = ::TestValueStruct (testObj.Parse "-123.45")
  expected = ::TestValueStruct -123.45
  assert (actual.Equals expected == true)
  -- 指数
  actual = ::TestValueStruct (testObj.Parse "-1.23e+2")
  expected = ::TestValueStruct -1.23e+2
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
