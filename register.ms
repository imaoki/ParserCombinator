/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
(
  fileIn "AstNode.ms"
  fileIn "Failure.ms"
  fileIn "NotCollect.ms"
  fileIn "ParserCombinator.ms"

  if isProperty ::startupScriptLoader "RegisterScript" do (
    ::startupScriptLoader.RegisterScript (getSourceFileName())
    ::startupScriptLoader.Save()
  )
  ok
)
