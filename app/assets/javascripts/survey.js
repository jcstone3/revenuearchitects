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

  if(location.href.indexOf("compare") > -1)
  {
    console.log("old one");
  /*  $.ajax({
    type: 'GET',
    url: '/surveys/overall_chart',
    success: function(data,status,xhr){
        console.log(data);
        console.dir(data);
        console.log('1: '+data[1]);
      },
      error: function(xhr,status,error){
        console.log(xhr);
        console.log(error);
      }
    });*/
  }

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
  $.getJSON('/surveys/overall_chart', function (data) {

    $('#compare-chart').highcharts({
        xAxis: {
          categories: data[0]
        },
        yAxis: {
        },
        tooltip: {
            crosshairs: true,
            shared: true
        },
        series: [{
            name: 'Your Response',
            marker: {
                symbol: 'circle',
                fill: 'red',
                radius: 9,
                lineColor: '#666666',
                lineWidth: 2
            },
            data: data[1]

        }, {
            name: 'Avg Response',
            marker: {
              symbol: 'circle',
              radius: 9,
              lineColor: '#666666',
              lineWidth: 2
            },
            data: data[2]
        }]
    });
  });
  }
});
