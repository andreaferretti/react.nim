# nim js -o=spa.js spa.nim
import dom, jsconsole, react, future, macros

type
  Greet = ref object of RootObj
    name: cstring
  Greetings = ref object of StatelessComponent[Greet]
  MultiGreet = ref object of RootObj
    name1, name2: cstring
  Choice = ref object
    first: bool
  MultiGreetings = ref object of Component[MultiGreet, Choice]

proc greetings(): ReactComponent =
  defineComponent:
    proc renderComponent(g: Greetings): auto = p(
      Attrs(style: Style(color: "red"), onClick: () => console.log("clicked")),
      "Hello ",
      g.props.name
    )

    proc componentWillMount(g: Greetings) = console.log("Mounting")

    proc componentDidMount(g: Greetings) = console.log("Mounted")


proc component(t: typedesc[MultiGreetings]): auto =
  proc setState(c: Component[MultiGreet, Choice], state: Choice) {.importcpp.}

  # Begin user code
  proc render(m: MultiGreetings): auto =
    if m.state.first:
      React.createElement(greetings(), Greet(name: m.props.name1))
    else:
      React.createElement(greetings(), Greet(name: m.props.name2))

  proc componentWillMount(m: MultiGreetings) =
    discard window.setTimeout(() => m.setState(Choice(first: true)), 1000)

  proc getInitialState(props: MultiGreet): auto =
    Choice(first: false)
  # End user code

  var d = ReactDescriptor()

  d.render = proc(): auto =
    var this {.importc,nodecl.}: MultiGreetings
    return render(this)
  d.componentWillMount = proc() =
    var this {.importc,nodecl.}: MultiGreetings
    componentWillMount(this)
  proc getInitialState1(): auto {.exportc.} =
    var this {.importc,nodecl.}: MultiGreetings
    getInitialState(this.props)
  {.emit: "`d`.getInitialState = `getInitialState1`;" .}
  return React.createClass(d)

proc startApp() {.exportc.} =
  console.log React.version
  let
    content = document.getElementById("content")
    Hello = React.createElement(component(MultiGreetings), MultiGreet(name1: "Andrea", name2: "pippo"))
  ReactDOM.render(Hello, content)