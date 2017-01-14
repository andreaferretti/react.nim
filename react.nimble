# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Example React single page application"
license       = "Apache2"
skipDirs      = @["example"]

# Dependencies

requires "nim >= 0.14.3"

task example, "builds example application":
  --define: release
  switch("out", "example/app.js")
  --path: "."
  setCommand "js", "example/app.nim"