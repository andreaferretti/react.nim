# Package

version       = "0.2.0"
author        = "Andrea Ferretti"
description   = "Example React single page application"
license       = "Apache2"
skipDirs      = @["example"]

# Dependencies

requires "nim >= 0.18.0"

task example, "builds example application":
  --define: release
  switch("out", "example/app.js")
  --path: "."
  setCommand "js", "example/app.nim"