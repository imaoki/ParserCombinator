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
  local context
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()
  local anyCharDef = fileIn (pathUtility.GetFullPath @"..\AnyChar.ms")
  local charDef = fileIn (pathUtility.GetFullPath @"..\Char.ms")
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Context.ms")
  local manyDef = fileIn (pathUtility.GetFullPath @"..\Many.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Lookahead.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  testObj = testDef #(
    manyDef (charDef "abcdefghijklmnopqrstuvwxyz") 1,
    charDef "."
  ) Debug:false
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一文字
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 失敗
  context = contextDef ".bar"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = contextDef "foo.bar.hoge"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct #("f", "o", "o")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
