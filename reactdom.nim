import macros
import react

type NodeOrString = ReactNode or seq[ReactNode] or cstring or string

macro idString(x: untyped): auto = newStrLitNode($x)

template tocstring(x: typed): auto =
  when x is string: cstring(x)
  else: x

template makeDomElement(x: untyped, name: string = nil) =
  const tag {.gensym.} = if name == nil: cstring(idString(x)) else: name

  proc x*(a: Attrs): ReactNode =
    React.createElement(tag, a)
  proc x*(a: Attrs, n1: NodeOrString): ReactNode =
    let m1 = n1.tocstring
    React.createElement(tag, a, m1)
  proc x*(a: Attrs, n1, n2: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
    React.createElement(tag, a, m1, m2)
  proc x*(a: Attrs, n1, n2, n3: NodeOrString): ReactNode =
    let
      m1 = n1.tocstring
      m2 = n2.tocstring
      m3 = n3.tocstring
    React.createElement(tag, a, m1, m2, m3)
  proc x*(a: Attrs, n1, n2, n3, n4: NodeOrString): ReactNode =
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

makeDomElement(a)
makeDomElement(abbr)
makeDomElement(address)
makeDomElement(area)
makeDomElement(article)
makeDomElement(aside)
makeDomElement(audio)
makeDomElement(b)
makeDomElement(base)
makeDomElement(bdi)
makeDomElement(bdo)
makeDomElement(big)
makeDomElement(blockquote)
makeDomElement(body)
makeDomElement(br)
makeDomElement(button)
makeDomElement(canvas)
makeDomElement(caption)
makeDomElement(cite)
makeDomElement(code)
makeDomElement(col)
makeDomElement(colgroup)
makeDomElement(data)
makeDomElement(datalist)
makeDomElement(dd)
makeDomElement(del)
makeDomElement(details)
makeDomElement(dfn)
makeDomElement(dialog)
makeDomElement(htmldiv, "div")
makeDomElement(dl)
makeDomElement(dt)
makeDomElement(em)
makeDomElement(embed)
makeDomElement(fieldset)
makeDomElement(figcaption)
makeDomElement(figure)
makeDomElement(footer)
makeDomElement(form)
makeDomElement(h1)
makeDomElement(h2)
makeDomElement(h3)
makeDomElement(h4)
makeDomElement(h5)
makeDomElement(h6)
makeDomElement(head)
makeDomElement(header)
makeDomElement(hgroup)
makeDomElement(hr)
makeDomElement(html)
makeDomElement(i)
makeDomElement(iframe)
makeDomElement(img)
makeDomElement(input)
makeDomElement(ins)
makeDomElement(kbd)
makeDomElement(keygen)
makeDomElement(label)
makeDomElement(legend)
makeDomElement(li)
makeDomElement(link)
makeDomElement(main)
makeDomElement(map)
makeDomElement(mark)
makeDomElement(menu)
makeDomElement(menuitem)
makeDomElement(meta)
makeDomElement(meter)
makeDomElement(nav)
makeDomElement(noscript)
makeDomElement(`object`)
makeDomElement(ol)
makeDomElement(optgroup)
makeDomElement(option)
makeDomElement(output)
makeDomElement(p)
makeDomElement(param)
makeDomElement(picture)
makeDomElement(pre)
makeDomElement(progress)
makeDomElement(q)
makeDomElement(rp)
makeDomElement(rt)
makeDomElement(ruby)
makeDomElement(s)
makeDomElement(samp)
makeDomElement(script)
makeDomElement(section)
makeDomElement(select)
makeDomElement(small)
makeDomElement(source)
makeDomElement(span)
makeDomElement(strong)
makeDomElement(style)
makeDomElement(sub)
makeDomElement(summary)
makeDomElement(sup)
makeDomElement(table)
makeDomElement(tbody)
makeDomElement(td)
makeDomElement(textarea)
makeDomElement(tfoot)
makeDomElement(th)
makeDomElement(thead)
makeDomElement(time)
makeDomElement(title)
makeDomElement(tr)
makeDomElement(track)
makeDomElement(u)
makeDomElement(ul)
makeDomElement(`var`)
makeDomElement(video)
makeDomElement(wbr)