$.fn.fixedHeader = function (options) {
 var config = {
   topOffset: $('nav').height(), //  height of StaffCare Masthead
   bgColor: '#FFFFFF',
   wait_msecs: 1000,
   column_freeze: false
 };
 if (options){ $.extend(config, options); }

 return this.each( function() {
  var o = $(this);

  var $win = $(window)
    , $head = $('thead.header', o)
    , isFixed = 0;
  var headTop = $head.length && $head.offset().top;
  var headLeft = $head.length && $head.offset().left;
  var zoom = o.parent().css('zoom');

  $head.clone().removeClass('header').addClass('header-copy header-fixed').appendTo(o);

  function set_css() {
      var ww = [];
      var ww_sum = 0;

      zoom = o.parent().css('zoom');

      o.find('thead.header > tr:first > th').each(function (i, h){
        ww.push($(h).outerWidth(true));
      });

      $.each(ww, function (i, w){
        o.find('thead.header-copy > tr > th:eq('+i+')').css({width: w});
      });

      $.each(ww, function (i, w){ ww_sum += parseInt(w) || 0;});

      o.find('thead.header-copy').css({ 'z-index': 20, 'width': ww_sum,'background-color': config.bgColor, 'position': 'fixed', 'top': config.topOffset / zoom });
    }

  setTimeout(function () { set_css() }, config.wait_msecs); // May need to wait for bootstrap to resize columns after knockout injects bound data

  function processScroll() {
    if (!o.is(':visible')) return;
    headTop = $head.offset().top;
    headLeft = $head.offset().left;

    var z = o.parent().css('zoom');
    if (z != zoom ) {
      zoom = z;
      set_css();
      o.find('thead.header-copy').css({ 'top': config.topOffset / zoom });
    };

    var i, scrollTop = $win.scrollTop() + config.topOffset / zoom;
    var j, scrollLeft = $win.scrollLeft();
    if      (scrollTop >=headTop && !isFixed) { isFixed = 1; }
    else if (scrollTop < headTop && isFixed) { isFixed = 0; }

    isFixed ? $('thead.header-copy', o).removeClass('hide')
            : $('thead.header-copy', o).addClass('hide');
    if (isFixed) {
      o.find('thead.header-copy').css({ 'left': -1 * (scrollLeft - headLeft) });
    };

    if (config.column_freeze) {
      if (scrollLeft >= headLeft) {
        o.find('tbody > tr > th').css({'position': 'relative', 'left': scrollLeft - headLeft, 'z-index': 10, 'opacity': 1, 'background-color': config.bgColor});
      } else {
        o.find('tbody > tr > th').css({'position': 'relative', 'left': 0, 'z-index': 10, 'opacity': 1, 'background-color': config.bgColor});
      };
    };

  }

  $win.on('scroll', processScroll);

  $win.scrollStopped(function(){
    processScroll();
  });

  $win.on('resize', function () {
      headTop = $head.offset().top;
      headLeft = $head.offset().left;
      set_css();
  });

  // hack sad times - holdover until rewrite for 2.1
  $head.on('click', function () {
    if (!isFixed) setTimeout(function () {  $win.scrollTop($win.scrollTop() - 47) }, 10);
  })

  processScroll();
 });

};

$.fn.scrollStopped = function(callback) {
    var $this = $(this), self = this;
    $this.scroll(function(){
        if ($this.data('scrollTimeout')) {
          clearTimeout($this.data('scrollTimeout'));
        }
        $this.data('scrollTimeout', setTimeout(callback,250,self));
    });
};