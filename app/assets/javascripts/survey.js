$(".surveys.question").ready(function() {
  cookies_string = document.cookie.split(';');
  str = 'popup_model';
  var popup_present;
  for (var j=0; j<cookies_string.length; j++) {
    if (cookies_string[j].match(str)){
     popup_present = cookies_string[j];
    }
  }
  if (popup_present!='undefined'){
    if (popup_present.split('=')[1]=='true'){
      $('#popup-notice').modal('show');
      $('#popup-notice').css("z-index","1050");
    }
    else{
      $('#popup-notice').modal('hide');
      $('#popup-notice').css("z-index","0");
      $('#popup-notice').remove();
    }
  }

  $("#prevent_popup").live('change', function(){
    var checked;
    if ($(this).is(':checked')) {
      checked = false;
    } else {
      checked = true;
    }

    $.ajax({
      url: '/surveys/prevent_popup',
      type: 'POST',
      data: {"checked": checked}
    });
  });

});

$(window).load(function() {

  $('#resultTable_filter').find('input').attr('placeholder','Search');
  $('#Search_All').attr('placeholder','Search');

  $.fn.dataTableExt.oApi.fnFilterAll = function (oSettings, sInput, iColumn, bRegex, bSmart) {
     var settings = $.fn.dataTableSettings;

     for (var i = 0; i < settings.length; i++) {
         settings[i].oInstance.fnFilter(sInput, iColumn, bRegex, bSmart);
     }
  };

  $(document).ready(function () {

     $('#report_ProgramTable').dataTable({
       "bPaginate": false,
       "bDestroy": true,
       "bInfo": false

     });
     var oTable0 = $("#report_ProgramTable").dataTable();

     $("#Search_All").keyup(function () {
       // Filter on the column (the index) of this element
       oTable0.fnFilterAll(this.value);
     });


     $('#report_SystemTable').dataTable({
       "bPaginate": false,
       "bDestroy": true,
       "bInfo": false

     });
     var oTable1 = $("#report_SystemTable").dataTable();

     $("#Search_All").keyup(function () {
       // Filter on the column (the index) of this element
       oTable1.fnFilterAll(this.value);
     });

     $('#report_StrategyTable').dataTable({
       "bPaginate": false,
       "bDestroy": true,
       "bInfo": false

     });
     var oTable2 = $("#report_StrategyTable").dataTable();

     $("#Search_All").keyup(function () {
       // Filter on the column (the index) of this element
       oTable2.fnFilterAll(this.value);
     });



     $('#report_prioritiesTable').dataTable({
       "bPaginate": false,
       "bDestroy": true,
       "bInfo": false

     });
     var oTable3 = $("#report_prioritiesTable").dataTable();

     $("#Search_All").keyup(function () {
       // Filter on the column (the index) of this element
       oTable3.fnFilterAll(this.value);
     });

     $('#report_add_to_planTable').dataTable({
       "bPaginate": false,
       "bDestroy": true,
       "bInfo": false

     });

     var oTable4 = $("#report_add_to_planTable").dataTable();

     $("#Search_All").keyup(function () {
       // Filter on the column (the index) of this element
       oTable4.fnFilterAll(this.value);
     });

     $('a[data-toggle="tab"]').on('click', function (e) {
        $("#Search_All").val('');
      });

      var hash = location.hash
      $('a[href$="'+hash+'"]').trigger( "click" );
      location.hash='';
  });
});


$(function () {
  if(location.href.indexOf("compare") > -1)
  {
    var route
    if(location.href.indexOf("strategy") > -1)
    {
      route = '/surveys/compare_strategy_chart';

    }else if (location.href.indexOf("system") > -1) {

      route = '/surveys/compare_systems_chart';

    }else if (location.href.indexOf("program") > -1) {

      route = '/surveys/compare_programs_chart';

    }else{

      route = '/surveys/overall_chart';
    }

  $.getJSON(route, function (data) {
    console.log(data);
    var options = {
      title: {
          text: 'Your Score vs. Average Score',
          align: 'right',
          x: 133,
          y: 115
      },
        chart: {
            type: 'line',
            width: 950,
            height: 350
        },
        xAxis: {
          title: {
            text: 'PRACTICE',
            align: 'left',
            y: -18
          },
          categories: data[0],
          gridLineColor: '#FFFFFF',
          lineColor: '#8D969B',
          lineWidth: 2
        },
        legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'middle',
          borderWidth: 0,
          itemMarginTop: 15,
          itemMarginBottom: 5,
          itemStyle: {
              lineHeight: '20px'
          }
        },
        yAxis: {
          title: {
            text: ''
          },
          gridLineColor: '#FFFFFF',
          lineColor: '#8D969B',
          lineWidth: 2
        },
        tooltip: {
            crosshairs: true,
            shared: true
        },
        series: [{
            name: 'Your Response',
            color: '#56C9F3',
            marker: {
                symbol: 'circle',
                fill: 'red',
                radius: 7,
                fillColor: '#FFFFFF',
                lineColor: '#56C9F3',
                lineWidth: 2
            },
            data: data[1]

        }, {
            name: 'Average Response',
            color: '#EA722F',
            marker: {
              symbol: 'circle',
              radius: 7,
              fillColor: '#FFFFFF',
              lineColor: '#EA722F',
              lineWidth: 2
            },
            data: data[2]
        }]
    }

    $('#compare-chart').highcharts(options);
    $('#compare-chart-strategy').highcharts(options);
    $('#compare-chart-systems').highcharts(options);
    $('#compare-chart-programs').highcharts(options);

  });
  }
});
