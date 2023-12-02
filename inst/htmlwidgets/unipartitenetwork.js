HTMLWidgets.widget({
  name: 'unipartitenetwork',
  type: 'output',

  factory: function(el, width, height) {
    var margin = { top: 20, right: 20, bottom: 30, left: 50 },
        innerWidth = width - margin.left - margin.right,
        innerHeight = height - margin.top - margin.bottom;

    var d3 = d3v5;
    
    var svg = d3.select(el).append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    function renderValue(x) {
      svg.selectAll('*').remove();

     // TODO make a network  
  
  return svg.node();
    }

    return {
      renderValue: renderValue,

      resize: function(newWidth, newHeight) {
        svg.attr('width', newWidth).attr('height', newHeight);
        innerWidth = newWidth - margin.left - margin.right;
        innerHeight = newHeight - margin.top - margin.bottom;
        // TODO make sure resizing works
        renderValue(svg.datum());
      }
    };
  }
});
