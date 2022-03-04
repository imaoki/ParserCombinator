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
  local context
  local failure = (fileIn (pathUtility.GetFullPath @"..\..\Model\Failure.ms"))()
  local notCollect = (fileIn (pathUtility.GetFullPath @"..\..\Model\NotCollect.ms"))()
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Model\Context.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Boundary.ms")
  testObj = testDef Debug:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 先端
  context = contextDef "  "
  context.Seek 0
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 終端
  context = contextDef "  "
  context.Seek 2
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 空白同士の境界
  context = contextDef "  "
  context.Seek 1
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 空白とアルファベットの境界
  context = contextDef " ab "
  context.Seek 1
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- アルファベットとアルファベットの境界
  context = contextDef " ab "
  context.Seek 2
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- アルファベットと空白の境界
  context = contextDef " ab "
  context.Seek 3
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- アルファベットとアンダースコアの境界
  context = contextDef " a_ "
  context.Seek 2
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- アンダースコアと空白の境界
  context = contextDef " a_ "
  context.Seek 3
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- アルファベットと数字の境界
  context = contextDef " a0 "
  context.Seek 2
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 数字と空白の境界
  context = contextDef " a0 "
  context.Seek 3
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 記号とアルファベットの境界
  context = contextDef " (ab) "
  context.Seek 2
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
