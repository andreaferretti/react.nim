# Package

version       = "0.1.0"
author        = "Andrea Ferretti"
description   = "Example React single page application"
license       = "Apache2"

# Dependencies

requires "nim >= 0.14.3"

task dist, "builds application":
  --define: release
  switch("out", "spa.js")
  --path: "."
  setCommand "js", "spa"