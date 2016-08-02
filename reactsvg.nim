import macros
import react

type NodeOrString = ReactNode or seq[ReactNode] or cstring or string

macro idString(x: untyped): auto = newStrLitNode($x)

template tocstring(x: typed): auto =
  when x is string: cstring(x)
  else: x

template makeSvgElement(x: untyped, name: string = nil) =
  const tag {.gensym.} = if name == nil: cstring(idString(x)) else: name

  proc x*(a: SvgAttrs): ReactNode =
    React.createElement(tag, a)
  proc x*(a: SvgAttrs, n1: NodeOrString): ReactNode =
    let m1 = n1.tocstring
    React.createElement(tag, a, m1)
  proc x*(a: SvgAttrs, n1, n2: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
    React.createElement(tag, a, m1, m2)
  proc x*(a: SvgAttrs, n1, n2, n3: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
      m3 = n3.tocstring
    React.createElement(tag, a, m1, m2, m3)
  proc x*(a: SvgAttrs, n1, n2, n3, n4: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
      m3 = n3.tocstring
      m4 = n4.tocstring
    React.createElement(tag, a, m1, m2, m3, m4)

  proc x*(n1: NodeOrString): ReactNode =
    let m1 = n1.tocstring
    React.createElement(tag, nil, m1)
  proc x*(n1, n2: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
    React.createElement(tag, nil, m1, m2)
  proc x*(n1, n2, n3: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
      m3 = n3.tocstring
    React.createElement(tag, nil, m1, m2, m3)
  proc x*(n1, n2, n3, n4: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
      m3 = n3.tocstring
      m4 = n4.tocstring
    React.createElement(tag, nil, m1, m2, m3, m4)

makeSvgElement(circle)
makeSvgElement(clipPath)
makeSvgElement(defs)
makeSvgElement(ellipse)
makeSvgElement(g)
makeSvgElement(image)
makeSvgElement(line)
makeSvgElement(linearGradient)
makeSvgElement(mask)
makeSvgElement(path)
makeSvgElement(pattern)
makeSvgElement(polygon)
makeSvgElement(polyline)
makeSvgElement(radialGradient)
makeSvgElement(rect)
makeSvgElement(stop)
makeSvgElement(svg)
makeSvgElement(text)
makeSvgElement(tspan)