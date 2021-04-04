# This is just an example to get you started. Users of your hybrid library will
# import this file by writing ``import Dotparserpkg/submodule``. Feel free to rename or
# remove this file altogether. You may create additional modules alongside
# this file as required.
import regex, strformat

type
  Lexem* = enum
    GRAPH, SUBGRAPH, NODE, EDGE, STRICT, CURLY_OPEN, CURLY_CLOSE, SEMICOLON, EQUAL, SQUARE_OPEN, SQUARE_CLOSE, COLON, COMMA, EDGE_OP, IGNORE, WHITESPAC, NEWLINE, ID, EOF

type
  Token* = object
    line*: int
    column*: int
    token*: Lexem
    content*: string

type
  Lexer* = object
    tokens*: seq[Token]

type
  LexingException* = object of Exception


let tokens = {GRAPH: re"graph|digraph",
        SUBGRAPH: re"subgraph",
        NODE: re"node",
        EDGE: re"edge",
        STRICT: re"strict",
        CURLY_OPEN: re"{",
        CURLY_CLOSE: re"}",
        SEMICOLON: re";",
        EQUAL: re"=",
        SQUARE_OPEN: re"\[",
        SQUARE_CLOSE: re"\]",
        COLON: re":",
        COMMA: re",",
        EDGE_OP: re"(--)|(->)",
        ID: re"[""!A-Za-z_]+[0-9]*",
        NEWLINE:  re"[\n|\r]+",
        WHITESPAC:  re"[\s|\t]+"}


proc get_splitted*(input: string): Lexer =
  var lexer = Lexer(tokens: newSeq[Token]())
  var line = 1
  var column = 1
  var queue = input
  var matched_token = ""
  while len(queue) > 0:
    var replacement = false
    for reg in tokens:
      if startsWith(queue, reg[1]):
        let match = findAll(queue, reg[1])
        let matched_token = queue[match[0].boundaries]
        queue = queue[len(matched_token) .. len(queue)-1]
        column += len(matched_token)
        replacement = true
        if reg[0] == NEWLINE:
          line += 1
          column = 0
          break
        if reg[0] == WHITESPAC:
          break
        let token: Token = Token(line: line, column: column, token: reg[0], content: matched_token)
        lexer.tokens.insert(token, len(lexer.tokens))
        break
    if not replacement:
      raise newException(LexingException, fmt"Lexing error at line: {line} column: {column} . Unknown Token")

        #echo splitted
  return lexer


proc getWelcomeMessage*(): string = "Hello, World!"
