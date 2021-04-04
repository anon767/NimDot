# Graph Dot Parser for Nim

## Usage

```Nim
  let lexer = get_splitted("""digraph G {
"Welcome";
"To";
"Nim";
"Dot!";
"Welcome" -> "To";
"To" -> "Nim";
"To" -> "Dot!";
}
""")
  var parser = parser(lexer)
  parser.parse_graph()
```

## To-Do

1. Implement Subgraphs
2. More tests
3. Command Line Interoperability
4. Convert Grim graph to Dot