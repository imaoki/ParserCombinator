/*! © 2021 imaoki | MIT License | https://github.com/imaoki */
(
  fileIn @"Model\AstNode.ms"
  fileIn @"Model\Failure.ms"
  fileIn @"Model\NotCollect.ms"
  fileIn "ParserCombinator.ms"

  if isProperty ::startupLoader "RegisterFile" do (
    ::startupLoader.RegisterFile (getSourceFileName())
  )
  ok
)
