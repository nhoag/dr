file = '/data/dr.json'

timeAxis = ->
  time = {}
  for year in [1982..2014]
    time[year] = 0
  time

races = ->
  ['White', 'Black', 'Hispanic', 'Other']

preload = ->
  time = {}
  for t in races()
    time[t] = timeAxis()
  time

pop = (data) ->
  struct = preload()
  for k, v of data
    yr = /\d{4}$/.exec v['date']
    struct[v['race']][yr[0]]++
  struct

tally = (arg) ->
  count = {}
  for t in races()
    count[t] = []
  for a, b of pop
    for r, s of b
      z = new Date(r)
      m = z.getTime()/1000
      h = { x: m, y: s }
      count[a].push h
  count

buildVis = (count) ->
  palette = new Rickshaw.Color.Palette()
  graph = new Rickshaw.Graph( {
          element: document.querySelector("#chart"),
          width: 700,
          height: 450,
          renderer: 'area',
          preserve: true,
          series: [ 
                  {
                    name: "White",
                    color: palette.color(),
                    data: count['White']
                  },
                  {
                    name: "Black",
                    color: palette.color(),
                    data: count['Black']
                  },
                  {
                    name: "Hispanic",
                    color: palette.color(),
                    data: count['Hispanic']
                  },
                  {
                    name: "Other",
                    color: palette.color(),
                    data: count['Other']
                  }
          ]
  } )

  graph.render()

  preview = new Rickshaw.Graph.RangeSlider( {
    graph: graph,
    element: document.getElementById('preview'),
  } )

  hoverDetail = new Rickshaw.Graph.HoverDetail( {
    graph: graph
  } )

  legend = new Rickshaw.Graph.Legend( {
    element: document.querySelector('#legend'),
    graph: graph
  } )

  shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
    graph: graph,
    legend: legend
  } )

  smoother = new Rickshaw.Graph.Smoother( {
    graph: graph,
    element: $('#smoother')
  } )

  ticksTreatment = 'glow'

  xAxis = new Rickshaw.Graph.Axis.Time( {
    graph: graph,
    ticksTreatment: ticksTreatment,
    timeFixture: new Rickshaw.Fixtures.Time.Local()
  } )

  xAxis.render()

  yAxis = new Rickshaw.Graph.Axis.Y( {
    graph: graph,
    orientation: 'left',
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
    element: document.getElementById('y_axis'),
  } )

  yAxis.render()

  controls = new RenderControls( {
    element: document.querySelector('form'),
    graph: graph
  } )


$.getJSON file, (data) ->
  pop = pop(data)
  count = tally(pop)
  buildVis(count)
