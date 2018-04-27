# Package

version       = "0.1.1"
author        = "Andrea Ferretti"
description   = "Example React single page application"
license       = "Apache2"
skipDirs      = @["example"]

# Dependencies

requires "nim >= 0.16.0"

task example, "builds example application":
  --define: release
  switch("out", "example/app.js")
  --path: "."
  setCommand "js", "example/app.nim"