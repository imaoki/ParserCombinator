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
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()

  testDef = fileIn (pathUtility.GetFullPath @"..\Word.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 一文字
  actual = ::TestValueStruct (testObj.Parse "a")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空白文字のみ
  actual = ::TestValueStruct (testObj.Parse " ")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 複数アルファベット
  actual = ::TestValueStruct (testObj.Parse "foobar")
  expected = ::TestValueStruct "foobar"
  assert (actual.Equals expected == true)
  -- アンダースコア入り
  actual = ::TestValueStruct (testObj.Parse "foo_bar")
  expected = ::TestValueStruct "foo_bar"
  assert (actual.Equals expected == true)
  -- 空白区切り
  actual = ::TestValueStruct (testObj.Parse "foo bar")
  expected = ::TestValueStruct "foo"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
