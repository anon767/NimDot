# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import grim

import Dotparserpkg/lexer
import Dotparserpkg/parser
test "Test Parser":
  let lexer = get_splitted("""digraph G {
"Welcome";
"To";
"Web";
"GraphViz!";
"Welcome" -> "To";
"To" -> "Web";
"To" -> "GraphViz!";
}
""")
  var parser = parser(lexer)
  parser.parse_graph()
  var g = parser.graph
  check g.numberOfNodes == 4
  check g.numberOfEdges == 3