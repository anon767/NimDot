# Package

version       = "0.1.0"
author        = "Tom"
description   = "A Graphviz Dot parser"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["Dotparser"]


# Dependencies

requires "nim >= 1.4.4"
requires "regex == 0.19.0"
requires "grim"
