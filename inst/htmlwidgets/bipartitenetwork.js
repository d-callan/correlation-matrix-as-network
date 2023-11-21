HTMLWidgets.widget({
  name: 'bipartitenetwork',
  type: 'output',

  factory: function(el, width, height) {
    var margin = { top: 20, right: 20, bottom: 30, left: 50 },
        innerWidth = width - margin.left - margin.right,
        innerHeight = height - margin.top - margin.bottom;

    var d3 = d3v5;
    
    var svg = d3.select(el).append('svg')
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    function renderValue(x) {
      svg.selectAll('*').remove();

      var xScale = d3.scaleOrdinal().domain(['source', 'target']).range([0, innerWidth]);
      var yScale = d3.scalePoint().range([0, innerHeight])
        .domain(d3.map(x.data, function(d){ return d.source; }).keys());

      svg.selectAll('.node')
        .data(x.data)
        .enter()
        .append('circle')
        .attr('class', 'node')
        .attr('r', 5)
        .attr('cx', function(d) { return xScale('source'); })
        .attr('cy', function(d) { return yScale(d.source); })
        .enter()
        .append('circle')
        .attr('class', 'target')
        .attr('r', 5)
        .attr('cx', function(d) { return xScale('target'); })
        .attr('cy', function(d, i) { return (i * (innerHeight / x.data.length)); })
        .attr('fill', 'orange');

      svg.selectAll('.link')
        .data(x.data)
        .enter()
        .append('line')
        .attr('class', 'link')
        .attr('x1', function(d) { return xScale('source'); })
        .attr('y1', function(d) { return yScale(d.source); })
        .attr('x2', function(d) { return xScale('target'); })
        .attr('y2', function(d, i) { return (i * (innerHeight / x.data.length)); })
        .style('stroke', function(d) { return d.value > 0 ? 'green' : 'red'; })
        .style('stroke-width', function(d) { return Math.abs(d.value) * 2; });
    }

    return {
      renderValue: renderValue,

      resize: function(newWidth, newHeight) {
        svg.attr('width', newWidth).attr('height', newHeight);
        innerWidth = newWidth - margin.left - margin.right;
        innerHeight = newHeight - margin.top - margin.bottom;
        xScale.range([0, innerWidth]);
        yScale.range([0, innerHeight]);
        renderValue(svg.datum());
      }
    };
  }
});
