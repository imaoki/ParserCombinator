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
  local charDef = ::parserCombinatorDefinitionPool[@"Parser\Char.ms"]
  local eosDef = ::parserCombinatorDefinitionPool[@"Parser\EOS.ms"]
  local manyDef = ::parserCombinatorDefinitionPool[@"Parser\Many.ms"]

  local parser

  testDef = ::parserCombinatorDefinitionPool[@"Model\Cache.ms"]
  testObj = testDef()
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Write */
  -- `undefined`書き込み
  parser = charDef "1"
  actual = ::TestValueStruct (testObj.Write parser 0 0 undefined)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 文字列書き込み
  parser = charDef "a"
  actual = ::TestValueStruct (testObj.Write parser 0 1 "a")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `false`書き込み
  parser = eosDef()
  actual = ::TestValueStruct (testObj.Write parser 0 0 false)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 配列書き込み
  parser = manyDef (charDef "a")
  actual = ::TestValueStruct (testObj.Write parser 0 2 #("a", "a"))
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* Read */
  -- `undefined`読み込み
  parser = charDef "1"
  actual = ::TestValueStruct (testObj.Read parser 0)
  expected = ::TestValueStruct (
    DataPair Hit:true Cache:(DataPair End:0 Value:undefined)
  )
  assert (actual.Equals expected == true)
  -- 文字列読み込み
  parser = charDef "a"
  actual = ::TestValueStruct (testObj.Read parser 0)
  expected = ::TestValueStruct (
    DataPair Hit:true Cache:(DataPair End:1 Value:"a")
  )
  assert (actual.Equals expected == true)
  -- `false`読み込み
  parser = eosDef()
  actual = ::TestValueStruct (testObj.Read parser 0)
  expected = ::TestValueStruct (
    DataPair Hit:true Cache:(DataPair End:0 Value:false)
  )
  assert (actual.Equals expected == true)
  -- 配列読み込み
  parser = manyDef (charDef "a")
  actual = ::TestValueStruct (testObj.Read parser 0)
  expected = ::TestValueStruct (
    DataPair Hit:true Cache:(DataPair End:2 Value:#("a", "a"))
  )
  assert (actual.Equals expected == true)
  -- キャッシュ無し
  parser = charDef "b"
  actual = ::TestValueStruct (testObj.Read parser 0)
  expected = ::TestValueStruct (
    DataPair Hit:false Cache:undefined
  )
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
