var options = {
    responsive: [{
        breakpoint: 400,
        options: {
            chart: {
                width: 300
            }
        }
    }, {
        breakpoint: 350,
        options: {
            chart: {
                width: 300,
                height: 300
            }
        }
    }],
    series: $$$,
    chart: {
        type: 'donut',
        height: 500,
        width: 350,
        toolbar: {
            show: false
        },
        zoom: {
            enabled: false
        }
    },
    labels: $$$,
    colors: $$$,
    legend: {
        position: 'top',
        horizontalAlign: 'center',
        onItemClick: {
            toggleDataSeries: false
        }
    },
    tooltip: {
        y: {
            formatter: function(val) {
                return val + "%"
            }
        }
    },
    dataLabels: {
        enabled: false
    },
    title: {
        text: 'Flash rate',
        align: 'center',
        offsetY: -5,
        margin: 20,
    },
};

var chart = new ApexCharts(document.querySelector('#flash-rate'), options);
chart.render()