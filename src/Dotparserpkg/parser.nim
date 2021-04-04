import grim
import lexer
import tables
import strformat
type
  Parser* = ref object of RootObj
    graph*: Graph
    cur*: int
    lexer*: Lexer
type
  ParsingException* = object of IOError
proc formatValue[T](result: var string; value: T; specifier: string): void =
  result.add $value

proc consume*(parser: Parser) =
  parser.cur += 1

proc current*(parser: Parser): Token =
  parser.lexer.tokens[parser.cur]

proc look_ahead*(parser: Parser): Token =
  if len(parser.lexer.tokens) <= parser.cur+1:
    return Token(line: 0,column: 0, token: EOF, content: "")
  return parser.lexer.tokens[parser.cur+1]

proc error*(parser:Parser, expected: Lexem): auto =
  let found: Lexem = parser.current().token
  raise newException(ParsingException, fmt"Parsing error, expected {expected} but found {found}")

proc parse_attr(parser: Parser, attributes: var Table[string, Box]) : Table[string, Box] =
    if parser.current().token != ID:
      parser.error(ID)
    let key = parser.current().content
    parser.consume()
    if parser.current().token != EQUAL:
      parser.error(EQUAL)
    parser.consume()
    if parser.current().token != ID:
      parser.error(ID)
    let value = parser.current().content
    parser.consume()
    attributes[key] = guessBox(value)

proc parse_attr_list(parser: Parser, attributes: var Table[string, Box] ): Table[string, Box] =
  if parser.current().token != SQUARE_OPEN:
    return attributes
  parser.consume()
  var new_attributes = parser.parse_attr(attributes)
  if parser.current().token == SEMICOLON or parser.current().token == COMMA:
    parser.consume()
    return parser.parse_attr_list(new_attributes)
  elif parser.current().token == SQUARE_CLOSE:
    parser.consume()
    return new_attributes
  else:
    parser.error(SQUARE_CLOSE)
    return new_attributes

proc parse_attr_list(parser: Parser): Table[string, Box] =
  var attributes : Table[string, Box] = initTable[string, Box]()
  return parser.parse_attr_list(attributes)


proc parse_node_stmt(parser: Parser) =
  if parser.current().token != ID:
    parser.error(ID)
  let node = parser.current().content
  parser.consume()
  discard parser.graph.addNode(node, parser.parse_attr_list(), node)

proc parser*(lexer: Lexer): Parser =
  var parser = Parser(graph: newGraph(), cur: 0, lexer: lexer)
  return parser

proc parse_edge_stmt(parser: Parser) =
  if parser.current().token != ID:
    parser.error(ID)
  let source_node = parser.current().content
  parser.consume()
  if parser.current().token != EDGE_OP:
    parser.error(EDGE_OP)
  parser.consume()
  if parser.current().token != ID:
    parser.error(ID)
  let target_node = parser.current().content
  parser.consume()
  discard parser.graph.addEdge(source_node, target_node, "CONNECTION", parser.parse_attr_list())

proc parse_stmt_list(parser: Parser) =

  if parser.look_ahead().token == EDGE_OP and parser.current().token == ID:
    parser.parse_edge_stmt()
  elif parser.current().token == ID:
    parser.parse_node_stmt()

  if parser.current().token == CURLY_CLOSE:
    parser.consume()
    return
  elif parser.current().token == SEMICOLON or parser.current().token == COLON:
    parser.consume()
    parser.parse_stmt_list()
    return
  else:
    parser.error(CURLY_CLOSE)


proc parse_graph*(parser: Parser) =
  let literal: Lexem = parser.current().token
  case literal
  of STRICT:
    parser.consume()
    parser.parse_graph()
  of Lexem.GRAPH:
      parser.consume()
      if parser.current().token != ID:
        parser.error(ID)
      parser.graph.name = parser.lexer.tokens[parser.cur].content
      parser.consume()
      if parser.current().token != CURLY_OPEN:
        parser.error(CURLY_OPEN)
      parser.consume()
      parse_stmt_list(parser)
  else:
    parser.error(Lexem.GRAPH)




