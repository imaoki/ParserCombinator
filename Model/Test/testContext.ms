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
  fileIn (getFullPath @"..\..\definitionPool.ms")
  local errorDef = fileIn (pathUtility.GetFullPath @"..\Error.ms")

  testDef = fileIn (pathUtility.GetFullPath @"..\Context.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* EOS */
  testObj = testDef "foobar"
  actual = ::TestValueStruct (testObj.EOS())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 空コード
  testObj = testDef ""
  actual = ::TestValueStruct (testObj.EOS())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetLineNumber */
  testObj = testDef "foo\nbar\n\nbaz\nhogepiyo\n\n"
  -- 位置0
  actual = ::TestValueStruct (testObj.GetLineNumber 0)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 位置3（最初の改行コード）
  actual = ::TestValueStruct (testObj.GetLineNumber 3)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 位置11
  actual = ::TestValueStruct (testObj.GetLineNumber 11)
  expected = ::TestValueStruct 4
  assert (actual.Equals expected == true)

  /* GetOffset */
  testObj = testDef "foobar"
  actual = ::TestValueStruct (testObj.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 位置を進める
  actual = ::TestValueStruct (testObj.Seek 3)
  -- 確認
  actual = ::TestValueStruct (testObj.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)

  /* LogError */
  testObj = testDef "a\nb\nx\nd\ne\nf\n"
  -- 位置を進める
  actual = ::TestValueStruct (testObj.Seek 4)
  expected = ::TestValueStruct 4
  assert (actual.Equals expected == true)
  -- エラーを記録
  testObj.LogError 4 "c"

  /* GetLastError */
  -- エラーを取得
  actual = ::TestValueStruct (testObj.GetLastError())
  expected = ::TestValueStruct (
    errorDef Expected:"c" LineNumber:3 LineText:"x\n" Offset:4 OffsetChar:"x"
  )
  assert (actual.Equals expected == true)

  /* PrintDebugInfo */
  /* PrintError */

  /* Read */
  testObj = testDef "foobar"
  actual = ::TestValueStruct (testObj.Read 1)
  expected = ::TestValueStruct "f"
  assert (actual.Equals expected == true)
  -- 2文字分
  actual = ::TestValueStruct (testObj.Read 2)
  expected = ::TestValueStruct "oo"
  assert (actual.Equals expected == true)
  -- 現在の位置から終端まで
  actual = ::TestValueStruct (testObj.Read 10)
  expected = ::TestValueStruct "bar"
  assert (actual.Equals expected == true)
  -- 終端に達している
  actual = ::TestValueStruct (testObj.Read 1)
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)

  /* Seek */
  testObj = testDef "foobar"
  actual = ::TestValueStruct (testObj.Seek 2)
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 終端を超えた場合
  actual = ::TestValueStruct (testObj.Seek 10)
  expected = ::TestValueStruct 6
  assert (actual.Equals expected == true)

  /* SetStream */
  testObj = testDef "a"
  actual = ::TestValueStruct (testObj.Read 1)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- ストリーム変更
  testObj.SetStream "b"
  actual = ::TestValueStruct (testObj.Read 1)
  expected = ::TestValueStruct "b"
  assert (actual.Equals expected == true)

  /* SOS */
  testObj = testDef "foobar"
  actual = ::TestValueStruct (testObj.SOS())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 先端ではない場合
  testObj.Seek 1
  actual = ::TestValueStruct (testObj.SOS())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
