import dom, jsconsole, jsffi, strutils, sequtils, future
import react
from react/reactdom import ul, li, input, `div`

type
  Country = ref object of RootObj
    name: string
    population: int
  ItemFilter = ref object of RootObj
    countries: seq[Country]
    query: string
  ValueLink = ref object of RootObj
    value: string
    handler: proc(s: string)
  Countries = ref object of RootObj
    countries: seq[Country]
  Filter = ref object of RootObj
    query: string
  Search = ref object of StatelessComponent[ValueLink]
  Items = ref object of StatelessComponent[ItemFilter]
  TopLevel = ref object of Component[Countries, Filter]

##### Items

proc makeItems(): ReactComponent =
  defineComponent:
    proc renderComponent(xs: Items): auto =
      let
        f = xs.props
        countries = f.countries.filter((s) => s.name.toLowerAscii.contains(f.query))
        list = ul(countries.map((c) => li(
          Attrs{key: c.name},
          c.name & ": " & $c.population))
        )
      return `div`(Attrs{className: "col-md-4"}, list)

let items = makeItems()

##### Search

proc makeSearch(): ReactComponent =
  defineComponent:
    proc renderComponent(s: Search): auto =
      `div`(
        Attrs{className: "form-group"},
        input(Attrs{
          className: "form-control",
          onChange: proc(e: react.Event) = s.props.handler($e.target.value),
          value: s.props.value,
          placeholder: "Filter here",
          `type`: "text"
        })
      )

let search = makeSearch()

##### Top level

proc makeTopLevel(): ReactComponent =
  defineComponent:
    proc renderComponent(s: TopLevel): auto =
      `div`(
        Attrs{style: Style{marginTop: 50}},
        `div`(Attrs{className: "row"},
          `div`(Attrs{className: "col-md-4"},
            search(ValueLink(
              value: s.state.query,
              handler: proc(q: string) = s.setState(Filter(query: q))
            ))
          )
        ),
        `div`(Attrs{className: "row"},
          items(ItemFilter(
            countries: s.props.countries,
            query: s.state.query
          ))
        )
      )

    proc getInitialState(props: Countries): auto = Filter(query: "")

let topLevel = makeTopLevel()

##### Main

proc startApp() {.exportc.} =
  console.log React.version
  let
    countries = Countries(countries: @[
      Country(name: "Italy", population: 59859996),
      Country(name: "Mexico", population: 118395054),
      Country(name: "France", population: 65806000),
      Country(name: "Argentina", population: 40117096),
      Country(name: "Japan", population: 127290000)
    ])
    content = document.getElementById("content")
    Main = topLevel(countries)
  ReactDOM.render(Main, content)