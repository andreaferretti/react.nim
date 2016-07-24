import dom, jsconsole, strutils, sequtils, future
import react
from reactdom import section, h1, p, ul, li, input

type
  Country = ref object of RootObj
    name: string
    population: int
  ItemFilter = ref object of RootObj
    countries: seq[Country]
    query: string
  Items = ref object of StatelessComponent[ItemFilter]
  ValueLink = ref object of RootObj
    value: string
    handler: proc(s: string)
  Search = ref object of StatelessComponent[ValueLink]
  Countries = ref object of RootObj
    countries: seq[Country]
  Filter = ref object of RootObj
    query: string
  TopLevel = ref object of Component[Countries, Filter]
  # Greet = ref object of RootObj
  #   name: cstring
  # Greetings = ref object of StatelessComponent[Greet]
  # MultiGreet = ref object of RootObj
  #   name1, name2: cstring
  # Choice = ref object
  #   first: bool
  # MultiGreetings = ref object of Component[MultiGreet, Choice]

proc makeItems(): ReactComponent =
  defineComponent:
    proc renderComponent(xs: Items): auto =
      console.log xs.props.countries
      let
        f = xs.props
        countries = f.countries.filter((s) => s.name.toLower.contains(f.query))
        list = ul(countries.map((c) => li(Attrs(key: c.name), cstring(c.name & ": " & $c.population))))
      return section(Attrs(className: "col-md-4"), list)

    discard # TODO: adjust the macro so that this is not needed

let items = makeItems()

proc makeSearch(): ReactComponent =
  defineComponent:
    proc renderComponent(s: Search): auto =
      section( # TODO find a way to make div work
        Attrs(className: "form-group"),
        input(Attrs(
          className: "form-control",
          # onChange: (e) => s.props.handler(e.target.value),
          value: s.props.value,
          placeholder: "Filter here"
        ))
      )

    discard # TODO: adjust the macro so that this is not needed

let search = makeSearch()

proc makeTopLevel(): ReactComponent =
  defineComponent:
    proc renderComponent(s: TopLevel): auto =
      section(
        section(Attrs(className: "row", key: "search"),
          section(Attrs(className: "col-md-4"),
            React.createElement(search, ValueLink(
              value: s.state.query,
              handler: proc(q: string) = s.setState(Filter(query: q))
            ))
          )
        ),
        section(Attrs(className: "row", key: "list"),
          React.createElement(items, ItemFilter(
            countries: s.props.countries,
            query: s.state.query
          ))
        )
      )

    proc getInitialState(props: Countries): auto =
      Filter(query: "")

let topLevel = makeTopLevel()

# proc greetings(): ReactComponent =
#   defineComponent:
#     proc renderComponent(g: Greetings): auto =
#       section(
#         h1(cstring("Greetings!")), # TODO: avoid the need to put cstring here
#         p(
#           Attrs(style: Style(color: "red"), className: "some-class", onClick: () => console.log("clicked")),
#           cstring("Hello "),
#           g.props.name
#         )
#       )
#
#     proc componentWillMount(g: Greetings) = console.log("Mounting")
#
#     proc componentDidMount(g: Greetings) = console.log("Mounted")
#
#     proc componentWillReceiveProps(g: Greetings, p: Greet) =
#       console.log("Receiving props")
#       console.log(p)
#
#     proc shouldComponentUpdate(g: Greetings, p: Greet): bool =
#       console.log("Let us update the component")
#       return true
#
# let g = greetings()
#
# let f = ItemFilter(
#   countries: @[
#     Country(name: "Italy", population: 123456),
#     Country(name: "France", population: 1234567)
#   ],
#   query: "it"
# )
#
# proc multigreetings(): ReactComponent =
#   defineComponent:
#     proc renderComponent(m: MultiGreetings): auto =
#       if m.state.first:
#         section(
#           React.createElement(g, Greet(name: m.props.name1)),
#           React.createElement(items, f)
#         )
#       else:
#         React.createElement(g, Greet(name: m.props.name2))
#
#     proc componentWillMount(m: MultiGreetings) =
#       discard window.setTimeout(() => m.setState(Choice(first: true)), 1000)
#
#     proc getInitialState(props: MultiGreet): auto =
#       Choice(first: false)
#
# let mg = multigreetings()

proc startApp() {.exportc.} =
  console.log React.version
  let
    countries = Countries(countries: @[
      Country(name: "Italy", population: 123456),
      Country(name: "France", population: 1234567)
    ])
    content = document.getElementById("content")
    Main = React.createElement(topLevel, countries)
  ReactDOM.render(Main, content)