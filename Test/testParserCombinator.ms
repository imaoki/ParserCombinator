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
  fileIn (pathUtility.GetFullPath @"..\definitionPool.ms")
  local context
  local failure = (::parserCombinatorDefinitionPool[@"Model\Failure.ms"])()
  local notCollect = (::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"])()
  local parser

  testDef = fileIn (pathUtility.GetFullPath @"..\ParserCombinator.ms")
  testObj = testDef()
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Alphabet */
  parser = testObj.Alphabet debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 小文字
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 大文字
  context = testObj.Context "A"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "A"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 数字は失敗する
  context = testObj.Context "1"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* Diff */
  parser = testObj.Diff (testObj.Char "0123456789") (testObj.Char "0") debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- アルファベット
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- パーサBに一致する
  context = testObj.Context "0"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- パーサAに一致するがパーサBには一致しない
  context = testObj.Context "5"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "5"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* Digit */
  parser = testObj.Digit debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "5"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "5"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致しない
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* Flatten */
  -- 全て統合
  parser = testObj.Flatten (
    testObj.Sequence #(
      testObj.Char "a",
      testObj.Sequence #(
        testObj.Char "b",
        testObj.Sequence #(
          testObj.Char "c"
        )
      )
    )
  ) debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("a", "b", "c")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- 1次元目までを統合
  parser = testObj.Flatten (
    testObj.Sequence #(
      testObj.Char "a",
      testObj.Sequence #(
        testObj.Char "b",
        testObj.Sequence #(
          testObj.Char "c"
        )
      )
    )
  ) depth:1 debug:false
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("a", "b", #("c"))
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)

  /* ItemAt */
  -- 1番目の要素を取得
  parser = testObj.ItemAt (testObj.Many (testObj.Char "abc")) 1 debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- 2番目の要素を取得
  parser = testObj.ItemAt (testObj.Many (testObj.Char "abc")) 2 debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "b"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- 3番目の要素を取得
  parser = testObj.ItemAt (testObj.Many (testObj.Char "abc")) 3 debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "c"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- 最後の要素を取得
  parser = testObj.ItemAt (testObj.Many (testObj.Char "abc")) -1 debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "aaaaaaaaaabbbbbbbbbc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "c"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 20
  assert (actual.Equals expected == true)

  /* Join */
  parser = testObj.Join (
    testObj.Sequence #(
      testObj.Char "a",
      testObj.Many (testObj.Char "b")
    )
  ) debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "ab"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 区切り文字を指定
  parser = testObj.Join (
    testObj.Sequence #(
      testObj.Char "a",
      testObj.Many (testObj.Char "b")
    )
  ) separator:"@" debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "abbbc"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "a@b@b@b"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 4
  assert (actual.Equals expected == true)

  /* List */
  parser = testObj.List \
      (
        testObj.ItemAt (
          testObj.Sequence #(
            testObj.Skip (testObj.Many (testObj.Char " \t\r\n")),
            testObj.Digit()
          )
        ) -1
      ) \
      (
        testObj.Sequence #(
          testObj.Many (testObj.Char " \t\r\n"),
          testObj.Char ","
        )
      ) \
      debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 空白
  context = testObj.Context " "
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一文字
  context = testObj.Context "1"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("1")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 二文字
  context = testObj.Context "12"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("1")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 区切り文字
  context = testObj.Context "1,2"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("1", "2")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- 空白区切り
  context = testObj.Context "1 2"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("1")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致
  context = testObj.Context "1,2, 3,\n\t 4  ,5"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct #("1", "2", "3", "4", "5")
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 15
  assert (actual.Equals expected == true)

  /* LowerAlphabet */
  parser = testObj.LowerAlphabet debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 大文字は失敗する
  context = testObj.Context "A"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 小文字は一致する
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "a"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* Skip */
  parser = testObj.Skip (testObj.Char "a") debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 一致しない
  context = testObj.Context "b"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 一致する
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct notCollect
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* UpperAlphabet */
  parser = testObj.UpperAlphabet debug:false
  -- 空コード
  context = testObj.Context ""
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置は変わらない
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 小文字は失敗する
  context = testObj.Context "a"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 大文字は一致する
  context = testObj.Context "A"
  actual = ::TestValueStruct (parser.Parse context)
  expected = ::TestValueStruct "A"
  assert (actual.Equals expected == true)
  -- 位置が変わる
  actual = ::TestValueStruct (context.GetOffset())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
