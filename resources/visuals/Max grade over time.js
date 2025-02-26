 var options = {
     responsive: [{
             breakpoint: 700,
             options: {
                 chart: {
                     width: 500
                 }
             }
         },
         {
             breakpoint: 600,
             options: {
                 chart: {
                     width: 440
                 }
             }
         },
         {
             breakpoint: 500,
             options: {
                 chart: {
                     width: 380
                 }
             }
         },
         {
             breakpoint: 400,
             options: {
                 chart: {
                     width: 320
                 }
             }
         },
         {
             breakpoint: 350,
             options: {
                 chart: {
                     width: 260
                 }
             }
         }
     ],
     series: $$$,
     chart: {
         type: 'area',
         height: 500,
         width: 650,
         stacked: true,
         toolbar: {
             show: false
         },
         zoom: {
             enabled: false
         }
     },
     colors: $$$,
     dataLabels: {
         enabled: false
     },
     stroke: {
         curve: 'smooth'
     },
     title: {
         text: 'Max grade over time',
         align: 'center'
     },
     fill: {
         type: 'gradient',
         gradient: {
             opacityFrom: 0.6,
             opacityTo: 0.8,
         }
     },
     legend: {
         position: 'top',
         horizontalAlign: 'center',
         onItemClick: {
             toggleDataSeries: true
         },
         onItemHover: {
             highlightDataSeries: true
         }
     },
     tooltip: {
         x: {
             format: 'MMM yyyy'
         },
         y: {
             formatter: function(val, {
                 seriesIndex,
                 dataPointIndex,
                 w
             }) {
                 if (w.globals.series[seriesIndex][dataPointIndex] == undefined) {
                     return
                 }

                 var sum = 0;
                 var null_count = 0;
                 if (seriesIndex > 0) {

                     for (var i = 0; i < seriesIndex; i++) {
                         if (w.globals.series[i][dataPointIndex] == undefined) {
                             null_count++
                         } else if (w.globals.series[i][dataPointIndex] != undefined) {
                             sum += w.globals.series[i][dataPointIndex]
                         }
                     }
                 }
                 if (null_count > 0) {
                     sum += $$$
                 }
                 return $$$[val + sum]
             }
         }

     },
     yaxis: {
         labels: {
             formatter: function(val, index) {
                 return $$$[index]
             },
             minWidth: 15,
         },
         min: 0,
         max: $$$,
         tickAmount: $$$,
         title: {
             text: 'Your grade'
         }
     },
     xaxis: {
         type: 'datetime',
         categories: $$$,
         labels: {
             format: 'MMM yyyy'
         }
     },
 };

 var chart = new ApexCharts(document.querySelector('#max-grade-over-time'), options);
 chart.render()