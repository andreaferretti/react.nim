type Console* {.importc.} = ref object of RootObj

{.push importcpp .}

proc log*[A](console: Console, a: A)
proc debug*[A](console: Console, a: A)
proc info*[A](console: Console, a: A)
proc error*[A](console: Console, a: A)

{.pop.}
proc log*(console: Console, a: string) = console.log(cstring(a))
proc debug*(console: Console, a: string) = console.log(cstring(a))
proc info*(console: Console, a: string) = console.log(cstring(a))
proc error*(console: Console, a: string) = console.log(cstring(a))

var console* {.importc, nodecl.}: Console