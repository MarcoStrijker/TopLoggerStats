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
        bar: {
            horizontal: false,
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
    xaxis: {
        "type": 'category',
        "categories": $$$
    },
    yaxis: {
        min: 0,
        decimalsInFloat: 0,
        title: {
            text: 'Your ascends',
        },
        forceNiceScale: true,
        labels: {
            minWidth: 15,
        }
    }
};

var chart = new ApexCharts(document.querySelector('#$$$'), options);
chart.render()