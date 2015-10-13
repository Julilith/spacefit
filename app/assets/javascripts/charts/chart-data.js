
(function($){

    var _plot_options={
      series: {
        lines: {
          show: true,
          lineWidth: 1,
          fill: true,
          fillColor: {
            colors: [{
              opacity: 0.0
            }, {
              opacity: 0.2
            }]
          }
        },
        points: {
          radius: 5,
          show: true
        },
        shadowSize: 2
      },
      grid: {
        color: "#fff",
        hoverable: true,
        clickable: true,
        tickColor: "#f0f0f0",
        borderWidth: 0
      },
      colors: ["#3fcf7f"],
      xaxis: {
        mode: "categories",
        tickDecimals: 0
      },
      yaxis: {
        ticks: 5,
        tickDecimals: 0,
      },
      tooltip: true,
      tooltipOpts: {
        content: "%y.4 exercices on day %x.1",
        defaultTheme: false,
        shifts: {
          x: 0,
          y: 20
        }
      }
    }

  $(document).ready(function() {

    if ($("#flot-color").get(0)){
      var plot = $.plot($("#flot-color"), [{ data: mule.workoutData }], _plot_options  );
    }
  })
})(jQuery);
