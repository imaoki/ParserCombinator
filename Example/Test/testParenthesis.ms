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
  local failure = ::FailureStruct()
  local notCollect = ::NotCollectStruct()

  testDef = fileIn (pathUtility.GetFullPath @"..\Parenthesis.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)
  -- true
  actual = ::TestValueStruct (testObj.Parse "abc(def(ghi)(jkl(mno)))pq")
  expected = ::TestValueStruct #(
    "a",
    "b",
    "c",
    #(
      "d",
      "e",
      "f",
      #(
        "g",
        "h",
        "i"
      ),
      #(
        "j",
        "k",
        "l",
        #(
          "m",
          "n",
          "o"
        )
      )
    ),
    "p",
    "q"
  )
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
