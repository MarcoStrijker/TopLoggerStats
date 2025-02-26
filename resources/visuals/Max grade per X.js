 var options = {
     responsive: [{
         breakpoint: 700,
         options: {
             chart: {
                 width: 500
             }
         }
     }, {
         breakpoint: 600,
         options: {
             chart: {
                 width: 440
             }
         }
     }, {
         breakpoint: 500,
         options: {
             chart: {
                 width: 380
             }
         }
     }, {
         breakpoint: 400,
         options: {
             chart: {
                 width: 320
             }
         }
     }, {
         breakpoint: 350,
         options: {
             chart: {
                 width: 260
             }
         }
     }],
     series: $$$,
     chart: {
         type: 'bar',
         height: 500,
         width: $$$,
         stacked: true,
         toolbar: {
             show: false
         },
         zoom: {
             enabled: false
         },
         animations: {
            enabled: false
         }
     },
     plotOptions: {
         "bar": {
             "horizontal": false,
         }
     },
     colors: $$$,
     dataLabels: {
         enabled: false
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
     title: {
         text: '$$$',
         align: 'center'
     },
     tooltip: {
         y: {
             formatter: function(val, {
                 seriesIndex,
                 dataPointIndex,
                 w
             }) {
                 var sum = 0;
                 if (seriesIndex > 0) {
                     for (var i = 0; i < seriesIndex; i++) {
                         sum += w.globals.series[i][dataPointIndex]
                     }
                 }

                 return $$$[val + sum]
             }
         }
     },
     xaxis: {
         type: 'category',
         categories: $$$
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
             text: 'Your grade',
         }
     }
 };

 var chart = new ApexCharts(document.querySelector('#$$$'), options);
 chart.render()