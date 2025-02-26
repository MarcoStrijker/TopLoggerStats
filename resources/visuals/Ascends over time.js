var options = {
    responsive: [{
            breakpoint: 1500,
            options: {
                chart: {
                    width: 650
                }
            }
        },
        {
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
        width: 750,
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
        text: 'Ascends over time',
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
    xaxis: {
        type: 'datetime',
        categories: $$$,
        labels: {
            format: 'MMM yyyy'
        }
    },
    tooltip: {
        x: {
            format: 'MMM yyyy'
        }
    },
    yaxis: {
        min: 0,
        decimalsInFloat: 0,
        title: {
            text: 'Your ascends'
        },
        forceNiceScale: true,
        labels: {
            minWidth: 15,
        }
    }
};

var chart = new ApexCharts(document.querySelector('#ascends-over-time'), options);
chart.render()