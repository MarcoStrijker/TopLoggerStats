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
        type: 'bar',
        height: 500,
        width: $$$,
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
        bar: {
            horizontal: false
        }
    },
    fill: {
        type: 'solid',
        colors: ['#df007a', '#00b0e8']
    },
    dataLabels: {
        enabled: false
    },
    title: {
        text: '$$$',
        align: 'center'
    },
    xaxis: {
        type: 'category',
        categories: $$$,
    },
    yaxis: {
        min: 0,
        max: 5,
        tickAmount: 10,
        decimalsInFloat: 1,
        title: {
            text: 'Your average rating'
        },
        labels: {
            minWidth: 15,
        }
    }
};

var chart = new ApexCharts(document.querySelector('#$$$'), options);
chart.render()