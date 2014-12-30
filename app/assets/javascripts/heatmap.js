$(document).ready(function() {
  var d = $('#heatmaps_controller');
  if(d){
    formatHeatmap();
  }
});

function formatHeatmap() {
  $('td.percent').each(function(index, value){
    var t = $(this);
    var s = percentToColor(t.html());
    var r = formatPercent(t.html());
    t.css("background-color", s);
    t.html(r);
  });
}

function percentToColor(percent){
  if(percent && percent > 0){
    var v = 70 - Math.min( (percent*100)*70, 70); // percent comes in as a decimal so must be multiplied by 100
    return "hsl(" + v + ",100%,50%)"
  } else {
    return 'hsl(0,100%,100%)'
  }
}

function formatPercent(percent){
  if(percent && percent > 0){
    return (percent*100).toFixed(4) + '%'
  } else {
    return percent
  }
}