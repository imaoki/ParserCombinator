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
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Model\Context.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Token.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  testObj = testDef "hoge" Debug:false
  context = contextDef "hogehoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "hoge"
  assert (actual.Equals expected == true)
  -- 位置確認
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 4
  assert (actual.Equals expected == true)
  -- 再度取得
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "hoge"
  assert (actual.Equals expected == true)
  -- 終端に達している
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 大文字と小文字を無視しない設定
  testObj = testDef "hoge" false Debug:false
  -- 大文字
  context = contextDef "Hoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 小文字
  context = contextDef "hoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "hoge"
  assert (actual.Equals expected == true)
  -- 一致しない
  context = contextDef "foo"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
