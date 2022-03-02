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

  testDef = fileIn (pathUtility.GetFullPath @"..\Array.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 単語
  actual = ::TestValueStruct (testObj.Parse "foobar")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空配列
  actual = ::TestValueStruct (testObj.Parse "[]")
  -- actual.Dump()
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)
  -- 閉じ忘れ
  actual = ::TestValueStruct (testObj.Parse "[")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空白
  actual = ::TestValueStruct (testObj.Parse "[ \t\n]")
  -- actual.Dump()
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)
  -- 数値
  actual = ::TestValueStruct (testObj.Parse "[1]")
  -- actual.Dump()
  expected = ::TestValueStruct #(1)
  assert (actual.Equals expected == true)
  -- 文字列リテラル
  actual = ::TestValueStruct (testObj.Parse "[\"foobar\"]")
  -- actual.Dump()
  expected = ::TestValueStruct #("foobar")
  assert (actual.Equals expected == true)
  -- ブール値
  actual = ::TestValueStruct (testObj.Parse "[false]")
  -- actual.Dump()
  expected = ::TestValueStruct #(false)
  assert (actual.Equals expected == true)
  -- null
  actual = ::TestValueStruct (testObj.Parse "[null]")
  -- actual.Dump()
  expected = ::TestValueStruct #(undefined)
  assert (actual.Equals expected == true)
  -- 複数要素
  actual = ::TestValueStruct (testObj.Parse "[1, \"2\", false, null]")
  -- actual.Dump()
  expected = ::TestValueStruct #(1, "2", false, undefined)
  assert (actual.Equals expected == true)
  -- ネスト
  actual = ::TestValueStruct (testObj.Parse "[1, [2]]")
  -- actual.Dump()
  expected = ::TestValueStruct #(1, #(2))
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
