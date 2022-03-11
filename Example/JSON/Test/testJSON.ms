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

  local json = StringStream ""
  format "{\n" to:json
  format "  \"firstName\": \"John\",\n" to:json
  format "  \"lastName\": \"Smith\",\n" to:json
  format "  \"isAlive\": true,\n" to:json
  format "  \"age\": 27,\n" to:json
  format "  \"address\": {\n" to:json
  format "    \"streetAddress\": \"21 2nd Street\",\n" to:json
  format "    \"city\": \"New York\",\n" to:json
  format "    \"state\": \"NY\",\n" to:json
  format "    \"postalCode\": \"10021-3100\"\n" to:json
  format "  },\n" to:json
  format "  \"phoneNumbers\": [\n" to:json
  format "    {\n" to:json
  format "      \"type\": \"home\",\n" to:json
  format "      \"number\": \"212 555-1234\"\n" to:json
  format "    },\n" to:json
  format "    {\n" to:json
  format "      \"type\": \"office\",\n" to:json
  format "      \"number\": \"646 555-4567\"\n" to:json
  format "    }\n" to:json
  format "  ],\n" to:json
  format "  \"children\": [],\n" to:json
  format "  \"spouse\": null\n" to:json
  format "}\n" to:json
  json = json as String

  local jsonObj = Dictionary \
      #("firstName", "John") \
      #("lastName", "Smith") \
      #("isAlive", true) \
      #("age", 27) \
      #(
        "address",
        Dictionary \
            #("streetAddress", "21 2nd Street") \
            #("city", "New York") \
            #("state", "NY") \
            #("postalCode", "10021-3100")
      ) \
      #(
        "phoneNumbers",
        #(
          Dictionary \
              #("type", "home") \
              #("number", "212 555-1234"),
          Dictionary \
              #("type", "office") \
              #("number", "646 555-4567")
        )
      ) \
      #("children", #()) \
      #("spouse", undefined)

  testDef = fileIn (pathUtility.GetFullPath @"..\JSON.ms")
  testObj = testDef ShowError:false
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* Parse */
  -- 空コード
  actual = ::TestValueStruct (testObj.Parse "")
  expected = ::TestValueStruct failure
  assert (actual.Equals expected == true)
  -- サンプル
  actual = ::TestValueStruct (testObj.Parse json)
  expected = ::TestValueStruct jsonObj
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
