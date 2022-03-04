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

  testDef = fileIn (pathUtility.GetFullPath @"..\IgnoreCommentLine.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)
  -- 改行無し
  actual = ::TestValueStruct (testObj.Parse "foo bar baz")
  expected = ::TestValueStruct "foo bar baz"
  assert (actual.Equals expected == true)
  -- 改行有り
  actual = ::TestValueStruct (testObj.Parse "foo bar baz\n")
  expected = ::TestValueStruct "foo bar baz\n"
  assert (actual.Equals expected == true)
  -- 複数行
  actual = ::TestValueStruct (testObj.Parse "foo\nbar\nbaz\n")
  expected = ::TestValueStruct "foo\nbar\nbaz\n"
  assert (actual.Equals expected == true)
  -- 単一コメント行
  actual = ::TestValueStruct (testObj.Parse "#foo")
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)
  -- 複数行
  actual = ::TestValueStruct (testObj.Parse "foo\n#bar\n#baz\nhoge\n")
  expected = ::TestValueStruct "foo\nhoge\n"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
