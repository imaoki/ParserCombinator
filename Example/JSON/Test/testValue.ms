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

  testDef = fileIn (pathUtility.GetFullPath @"..\Value.ms")
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
  -- 文字列リテラル
  actual = ::TestValueStruct (testObj.Parse "\"foobar\"")
  expected = ::TestValueStruct "foobar"
  assert (actual.Equals expected == true)
  -- 前後が空白文字の文字列リテラル
  actual = ::TestValueStruct (testObj.Parse "\t\"foobar\"\n")
  expected = ::TestValueStruct "foobar"
  assert (actual.Equals expected == true)
  -- 整数
  actual = ::TestValueStruct (testObj.Parse "12")
  expected = ::TestValueStruct 12
  assert (actual.Equals expected == true)
  -- true
  actual = ::TestValueStruct (testObj.Parse "true")
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- false
  actual = ::TestValueStruct (testObj.Parse "false")
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- null
  actual = ::TestValueStruct (testObj.Parse "null")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 配列
  actual = ::TestValueStruct (testObj.Parse "[1, \"2\", false, null]")
  expected = ::TestValueStruct #(1, "2", false, undefined)
  assert (actual.Equals expected == true)
  -- オブジェクト
  actual = ::TestValueStruct (testObj.Parse "{ \"number\" : 1, \"string\": \"foobar\", \"boolean\": true, \"null\": null }")
  expected = ::TestValueStruct (
    Dictionary \
        #("number", 1) \
        #("string", "foobar") \
        #("boolean", true) \
        #("null", undefined)
  )
  assert (actual.Equals expected == true)
  -- ネスト
  actual = ::TestValueStruct (testObj.Parse "[[[[[[[[1]]]]]]]]")
  expected = ::TestValueStruct #(#(#(#(#(#(#(#(1))))))))
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
