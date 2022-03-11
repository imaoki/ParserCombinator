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
  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  local failure = (::parserCombinatorDefinitionPool[@"Model\Failure.ms"])()
  local notCollect = (::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"])()

  testDef = fileIn (pathUtility.GetFullPath @"..\ArithmeticOperations.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  -- actual.Dump()
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- アルファベット
  actual = ::TestValueStruct (testObj.Parse "abc")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse "+")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse "-")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse "*")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse "/")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse "(")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 記号のみ
  actual = ::TestValueStruct (testObj.Parse ")")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空白
  actual = ::TestValueStruct (testObj.Parse " ")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 整数のみ
  actual = ::TestValueStruct (testObj.Parse "0")
  -- actual.Dump()
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 整数のみ
  actual = ::TestValueStruct (testObj.Parse "-1")
  -- actual.Dump()
  expected = ::TestValueStruct -1
  assert (actual.Equals expected == true)
  -- 加算
  actual = ::TestValueStruct (testObj.Parse "2+3")
  -- actual.Dump()
  expected = ::TestValueStruct (2+3)
  assert (actual.Equals expected == true)
  -- 加算（空白付き）
  actual = ::TestValueStruct (testObj.Parse "2 + 3")
  -- actual.Dump()
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 加算と減算
  actual = ::TestValueStruct (testObj.Parse "4+5-6")
  -- actual.Dump()
  expected = ::TestValueStruct (4+5-6)
  assert (actual.Equals expected == true)
  -- 乗算
  actual = ::TestValueStruct (testObj.Parse "7*8")
  -- actual.Dump()
  expected = ::TestValueStruct (7*8)
  assert (actual.Equals expected == true)
  -- 乗算と除算
  actual = ::TestValueStruct (testObj.Parse "8*2/4")
  -- actual.Dump()
  expected = ::TestValueStruct (8*2/4)
  assert (actual.Equals expected == true)
  -- 加算と乗算
  actual = ::TestValueStruct (testObj.Parse "2+4*3")
  -- actual.Dump()
  expected = ::TestValueStruct (2+4*3)
  assert (actual.Equals expected == true)
  -- 加算と除算
  actual = ::TestValueStruct (testObj.Parse "4+6/2")
  -- actual.Dump()
  expected = ::TestValueStruct (4+6/2)
  assert (actual.Equals expected == true)
  -- 加算優先
  actual = ::TestValueStruct (testObj.Parse "(2+4)*3")
  -- actual.Dump()
  expected = ::TestValueStruct ((2+4)*3)
  assert (actual.Equals expected == true)
  -- マイナス値の加算
  actual = ::TestValueStruct (testObj.Parse "4+-2")
  -- actual.Dump()
  expected = ::TestValueStruct (4+-2)
  assert (actual.Equals expected == true)
  -- マイナス値の減算
  actual = ::TestValueStruct (testObj.Parse "4--2")
  -- actual.Dump()
  expected = ::TestValueStruct (4- -2)
  assert (actual.Equals expected == true)
  -- 全部入り
  actual = ::TestValueStruct (testObj.Parse "1+2*3-3/(1--1)")
  -- actual.Dump()
  expected = ::TestValueStruct (1+2*3-3/(1- -1))
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
