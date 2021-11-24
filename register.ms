/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
(
  fileIn "AstNode.ms"
  format "[define]::AstNodeStruct\n"

  fileIn "Failure.ms"
  format "[define]::FailureStruct\n"

  fileIn "NotCollect.ms"
  format "[define]::NotCollectStruct\n"

  fileIn "ParserCombinator.ms"
  format "[define]::ParserCombinatorStruct\n"

  if isProperty ::startupScriptLoader "RegisterScript" do (
    ::startupScriptLoader.RegisterScript (getSourceFileName())
    ::startupScriptLoader.Save()
  )
  ok
)
