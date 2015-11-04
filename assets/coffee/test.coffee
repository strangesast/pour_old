ps = document.querySelectorAll '.percentage'

removeInterval = (interval) ->
  (e) ->
    clearInterval interval

hoverListener = (item) ->
  interval = null
  return (e) ->
    t = e.target
    if t.classList.contains('percentage')
      elem = t
      val = t.getAttribute('toast')
    else if t.classList.contains('bar')
      elem = t.parentElement
      val = t.parentElement.getAttribute('toast')
  
    if elem?
      val = Number(val)
      interval = setInterval(() ->
        val++ 
        if val > 100
          val = 0
        elem.setAttribute 'toast', val
      , 100)
      item.addEventListener 'mouseleave', removeInterval(interval)
      item.addEventListener 'mouseout', removeInterval(interval)


for item in ps
  item.addEventListener 'mouseover', hoverListener(item), false
