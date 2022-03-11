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

  testDef = fileIn (pathUtility.GetFullPath @"..\String.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 引用符無し
  actual = ::TestValueStruct (testObj.Parse "foobar")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 単一引用符
  actual = ::TestValueStruct (testObj.Parse "'foobar'")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていないエスケープ文字（バックスラッシュ）
  actual = ::TestValueStruct (testObj.Parse "\"hoge\\piyo\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていないエスケープ文字（スラッシュ）
  actual = ::TestValueStruct (testObj.Parse "\"hoge/piyo\"")
  expected = ::TestValueStruct "hoge/piyo"
  assert (actual.Equals expected == true)
  -- エスケープしていない制御文字（Backspace）
  actual = ::TestValueStruct (testObj.Parse ("\"hoge" + Bit.IntAsChar 8 + "piyo\""))
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていない制御文字（Form Feed）
  actual = ::TestValueStruct (testObj.Parse ("\"hoge" + Bit.IntAsChar 12 + "piyo\""))
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていない制御文字（Line Feed）
  actual = ::TestValueStruct (testObj.Parse "\"hoge\npiyo\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていない制御文字（Carriage Return）
  actual = ::TestValueStruct (testObj.Parse "\"hoge\rpiyo\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープしていない制御文字（Horizontal Tabulation）
  actual = ::TestValueStruct (testObj.Parse "\"hoge\tpiyo\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 二重引用符閉じ忘れ
  actual = ::TestValueStruct (testObj.Parse "\"foobar")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 二重引用符
  actual = ::TestValueStruct (testObj.Parse "\"foobar\"")
  -- actual.Dump()
  expected = ::TestValueStruct "foobar"
  assert (actual.Equals expected == true)
  -- 二重引用符（空文字列）
  actual = ::TestValueStruct (testObj.Parse "\"\"")
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)
  -- エスケープしたエスケープ文字（引用符）
  actual = ::TestValueStruct (testObj.Parse "\"\\\"\"")
  expected = ::TestValueStruct "\""
  assert (actual.Equals expected == true)
  -- エスケープしたエスケープ文字（バックスラッシュ）
  actual = ::TestValueStruct (testObj.Parse "\"\\\\\"")
  expected = ::TestValueStruct "\\"
  assert (actual.Equals expected == true)
  -- エスケープしたエスケープ文字（スラッシュ）
  actual = ::TestValueStruct (testObj.Parse "\"\\/\"")
  expected = ::TestValueStruct "/"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（Backspace）
  actual = ::TestValueStruct (testObj.Parse "\"\\b\"")
  expected = ::TestValueStruct "\b"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（Form Feed）
  actual = ::TestValueStruct (testObj.Parse "\"\\f\"")
  expected = ::TestValueStruct "\f"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（Line Feed）
  actual = ::TestValueStruct (testObj.Parse "\"\\n\"")
  expected = ::TestValueStruct "\n"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（Carriage Return）
  actual = ::TestValueStruct (testObj.Parse "\"\\r\"")
  expected = ::TestValueStruct "\r"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（Horizontal Tabulation）
  actual = ::TestValueStruct (testObj.Parse "\"\\t\"")
  expected = ::TestValueStruct "\t"
  assert (actual.Equals expected == true)
  -- エスケープした制御文字（全て）
  actual = ::TestValueStruct (testObj.Parse "\"\\\"\\\\\\/\\b\\f\\n\\r\\t\"")
  expected = ::TestValueStruct "\"\\/\b\f\n\r\t"
  assert (actual.Equals expected == true)
  不完全な16進数ユニコード文字（字数不足）
  actual = ::TestValueStruct (testObj.Parse "\"\\u002\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 不完全な16進数ユニコード文字（範囲外の文字）
  actual = ::TestValueStruct (testObj.Parse "\"\\u002z\"")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- エスケープされていないスラッシュとエスケープした16進数ユニコード文字
  actual = ::TestValueStruct (testObj.Parse "\"[/\\/\\u002F\\u002f]\"")
  expected = ::TestValueStruct "[////]"
  assert (actual.Equals expected == true)
  -- サロゲートペア
  actual = ::TestValueStruct (testObj.Parse "\"\\ud83c\\udf63\"")
  expected = ::TestValueStruct "🍣"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
