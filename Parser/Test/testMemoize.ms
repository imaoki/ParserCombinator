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
  local charDef = fileIn (pathUtility.GetFullPath @"..\Char.ms")
  local contextDef = fileIn (pathUtility.GetFullPath @"..\..\Context.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Memoize.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  testObj = testDef (charDef "a") Debug:false
  -- キャッシュに架空データを書き込み
  context = contextDef ""
  context.WriteCache (charDef "a") 0 1 "b"
  -- キャッシュの読み込み
  actual = ::TestValueStruct (testObj.Parse context)
  expected = ::TestValueStruct "b"
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
