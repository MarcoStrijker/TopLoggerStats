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
    fill: {
        type: 'solid'
    },
    dataLabels: {
        enabled: false
    },
    title: {
        text: 'Rating accuracy',
        align: 'center'
    },
    xaxis: {
        type: 'numeric',
        min: 1,
        max: 5,
        tickAmount: 4,
        dataLabels: {
            enabled: false
        },
        decimalsInFloat: 0,
        title: {
            text: 'Your rating'
        }
    },
    yaxis: {
        min: 1,
        max: 5,
        tickAmount: 8,
        decimalsInFloat: 1,
        dataLabels: {
            enabled: false
        },
        title: {
            text: 'Average rating'
        }
    }
};

var chart = new ApexCharts(document.querySelector('#rating-accuracy'), options);
chart.render()