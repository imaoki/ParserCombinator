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
  local context
  local failure = (::parserCombinatorDefinitionPool[@"Model\Failure.ms"])()
  local notCollect = (::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"])()
  local contextDef = ::parserCombinatorDefinitionPool[@"Model\Context.ms"]

  testDef = ::parserCombinatorDefinitionPool[@"Parser\EOS.ms"]
  testObj = testDef Debug:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  context = contextDef ""
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 終端に達していない
  context = contextDef "a"
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置を進める
  context.Read 1
  -- 終端に達している
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
