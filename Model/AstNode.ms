/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
/*-
構文木のノード。
*/
struct AstNodeStruct (
  /*- @prop <Name> */
  public Type = #Unknown,
  /*- @prop <String|Array[<Struct:AstNodeStruct>]> */
  public Value,

  /*- @returns <Name> */
  public fn StructName = #AstNodeStruct,

  /*-
  @param v <Any>
  @param indent <String>
  @param out <FileStream|StringStream|WindowStream>
  @param delimiter: <String> 配列の区切り文字に使用する。既定値は`""`。
  @returns <OkClass>
  */
  private fn dumpValue v indent out delimiter:"" = (
    if this.isAstNode v then (
      v.Dump indent:indent out:out delimiter:delimiter
    )
    else (
      case classOf v of (
        (Array): (
          format "#(\n" to:out
          for i = 1 to v.Count do (
            if not this.isAstNode v[i] do (
              format "%  " indent to:out
            )
            local delimiterChar = if i == v.Count then "" else ","
            this.dumpValue v[i] (indent + "  ") out delimiter:delimiterChar
          )
          format "%)%\n" indent delimiter to:out
        )
        (String): (
          local valueText = ::std.StringUtility.EscapeBackslash v
          format "\"%\"%\n" valueText delimiter to:out
        )
        default: (
          local valueText = ::std.StringUtility.ToPascalCase v
          valueText = ::std.StringUtility.EscapeBackslash valueText
          format "%%\n" valueText delimiter to:out
        )
      )
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isAstNode obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #AstNodeStruct
  ),

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @param delimiter: <String> 配列の区切り文字に使用する。既定値は`""`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener delimiter:"" = (
    format "%AstNodeStruct" indent to:out
    format " Type:%" (::std.StringUtility.ToPascalCase this.Type) to:out
    if this.isAstNode this.Value then (
      format " Value:(\n" to:out
      this.dumpValue this.Value (indent + "  ") out delimiter:""
      format "%)%\n" indent delimiter to:out
    )
    else (
      format " Value:" to:out
      this.dumpValue this.Value indent out delimiter:delimiter
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    /*
    `Value`に構造体インスタンスが入っている場合
    たとえ同じ型でも異なるスコープで定義・生成されたものである可能性が高いため
    `classOf`で得られる型の比較を行うと失敗する。
    */
    local isEqualProperties = isProperty obj #Type \
        and classOf obj.Type == Name \
        and obj.Type == this.Type \
        and isProperty obj #Value

    if isEqualProperties do (
      local ov = obj.Value
      local tv = this.Value
      isEqualProperties = case classOf this.Value of (
        (Array): (
          local result = ov.Count == tv.Count
          for i = 1 to tv.Count while result do (
            local t1 = tv[i]
            local o1 = ov[i]
            if isProperty t1 #Equals \
                and classOf t1.Equals == MAXScriptFunction then (
              result = t1.Equals o1
            )
            else (
              result = o1 == t1
            )
          )
          result
        )
        default: (
          if isProperty tv #Equals \
              and classOf tv.Equals == MAXScriptFunction then (
            tv.Equals ov
          )
          else (
            ov == tv
          )
        )
      )
    )

    isEqualStructName and isEqualProperties
  ),

  on Create do ()
)
-- format "[define]::AstNodeStruct\n"
-- ::AstNodeStruct
