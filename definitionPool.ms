/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
global parserCombinatorDefinitionPool = Dictionary #String
/* 依存無し */
::parserCombinatorDefinitionPool[@"Model\AstNode.ms"] = fileIn @"Model\AstNode.ms"
::parserCombinatorDefinitionPool[@"Model\Cache.ms"] = fileIn @"Model\Cache.ms"
::parserCombinatorDefinitionPool[@"Model\Error.ms"] = fileIn @"Model\Error.ms"
::parserCombinatorDefinitionPool[@"Model\Failure.ms"] = fileIn @"Model\Failure.ms"
::parserCombinatorDefinitionPool[@"Model\NotCollect.ms"] = fileIn @"Model\NotCollect.ms"
/*
Cache.ms
Error.ms
*/
::parserCombinatorDefinitionPool[@"Model\Context.ms"] = fileIn @"Model\Context.ms"

/* 依存無し */
::parserCombinatorDefinitionPool[@"Parser\And.ms"] = fileIn @"Parser\And.ms"
::parserCombinatorDefinitionPool[@"Parser\AnyChar.ms"] = fileIn @"Parser\AnyChar.ms"
::parserCombinatorDefinitionPool[@"Parser\Choice.ms"] = fileIn @"Parser\Choice.ms"
::parserCombinatorDefinitionPool[@"Parser\Delay.ms"] = fileIn @"Parser\Delay.ms"
::parserCombinatorDefinitionPool[@"Parser\EOS.ms"] = fileIn @"Parser\EOS.ms"
::parserCombinatorDefinitionPool[@"Parser\Expect.ms"] = fileIn @"Parser\Expect.ms"
::parserCombinatorDefinitionPool[@"Parser\IsNot.ms"] = fileIn @"Parser\IsNot.ms"
::parserCombinatorDefinitionPool[@"Parser\Lookahead.ms"] = fileIn @"Parser\Lookahead.ms"
::parserCombinatorDefinitionPool[@"Parser\Many.ms"] = fileIn @"Parser\Many.ms"
::parserCombinatorDefinitionPool[@"Parser\Map.ms"] = fileIn @"Parser\Map.ms"
::parserCombinatorDefinitionPool[@"Parser\Memoize.ms"] = fileIn @"Parser\Memoize.ms"
::parserCombinatorDefinitionPool[@"Parser\Option.ms"] = fileIn @"Parser\Option.ms"
::parserCombinatorDefinitionPool[@"Parser\Partial.ms"] = fileIn @"Parser\Partial.ms"
::parserCombinatorDefinitionPool[@"Parser\Sequence.ms"] = fileIn @"Parser\Sequence.ms"
::parserCombinatorDefinitionPool[@"Parser\SOS.ms"] = fileIn @"Parser\SOS.ms"
::parserCombinatorDefinitionPool[@"Parser\Token.ms"] = fileIn @"Parser\Token.ms"
/*
AnyChar.ms
*/
::parserCombinatorDefinitionPool[@"Parser\Char.ms"] = fileIn @"Parser\Char.ms"
/*
Char.ms
*/
::parserCombinatorDefinitionPool[@"Parser\Boundary.ms"] = fileIn @"Parser\Boundary.ms"

::parserCombinatorDefinitionPool
