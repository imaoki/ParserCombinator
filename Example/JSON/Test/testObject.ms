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
  fileIn (pathUtility.GetFullPath @"..\..\..\definitionPool.ms")
  local failure = (::parserCombinatorDefinitionPool[@"Model\Failure.ms"])()
  local notCollect = (::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"])()

  testDef = fileIn (pathUtility.GetFullPath @"..\Object.ms")
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
  -- 空オブジェクト
  actual = ::TestValueStruct (testObj.Parse "{}")
  -- actual.Dump()
  expected = ::TestValueStruct (Dictionary #String)
  assert (actual.Equals expected == true)
  -- 閉じ忘れ
  actual = ::TestValueStruct (testObj.Parse "{")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- キーのみ（コロン無し）
  actual = ::TestValueStruct (testObj.Parse "{ \"foo-bar\" }")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- キーのみ（コロン有り）
  actual = ::TestValueStruct (testObj.Parse "{ \"foo-bar\": }")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 値のみ
  actual = ::TestValueStruct (testObj.Parse "{ : 12 }")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 一つの値
  actual = ::TestValueStruct (testObj.Parse "{ \"foo-bar\": 12 }")
  -- actual.Dump()
  expected = ::TestValueStruct (Dictionary #("foo-bar", 12))
  assert (actual.Equals expected == true)
  -- カンマ終わり
  actual = ::TestValueStruct (testObj.Parse "{ \"foo-bar\": 12, }")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 複数の値
  actual = ::TestValueStruct (
    testObj.Parse "{ \"number\" : 1, \"string\": \"foobar\", \"boolean\": true, \"null\": null }"
  )
  -- actual.Dump()
  expected = ::TestValueStruct (
    Dictionary \
        #("number", 1) \
        #("string", "foobar") \
        #("boolean", true) \
        #("null", undefined)
  )
  assert (actual.Equals expected == true)
  -- ネスト
  actual = ::TestValueStruct (
    testObj.Parse "{ \"object\" : { \"array\": [1, \"foobar\"]} }"
  )
  -- actual.Dump()
  expected = ::TestValueStruct (
    Dictionary #("object", Dictionary #("array", #(1, "foobar")))
  )
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
