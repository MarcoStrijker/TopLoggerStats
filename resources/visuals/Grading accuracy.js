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
        type: 'scatter',
        height: 500,
        width: 500,
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
    colors: $$$,
    legend: {
        show: false
    },
    fill: {
        type: 'solid'
    },
    markers: {
        size: 9,
    },
    dataLabels: {
        enabled: false
    },
    title: {
        text: 'Grading accuracy',
        align: 'center'
    },
    xaxis: {
        type: 'numeric',
        min: 0,
        max: $$$,
        tickAmount: $$$,
        labels: {
            formatter: function(val) {
                return $$$[val]
            }
        },
        title: {
            text: 'Your grade'
        }
    },
    yaxis: {
        min: 0,
        max: $$$,
        tickAmount: $$$,
        labels: {
            formatter: function(val) {
                return $$$[val]
            }
        },
        title: {
            text: 'Average grade'
        }
    }
};

var chart = new ApexCharts(document.querySelector('#grading-accuracy'), options);

chart.render()