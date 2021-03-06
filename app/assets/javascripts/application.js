// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require rails.validations
//= jquery-ui-1.8.18.custom.min
//= require twitter/bootstrap
//= require bootstrap
//= require jquery.feedback
//= require jquery-readyselector
//= require_tree .

$(document).ready(function(){
  /* Your javascripts goes here... */
  //to hide and show login and signup
                 $(".alert").fadeOut(5000);
        $('#signup_user').hide();

        var login_val = $('#login').val();

        if(login_val == "yes"){
               $('#signup_user').show();
               $('#login_user').hide();
        }
        else{
          $('#signup_user').hide();
          $('#login_user').show();
        }
            //----------end of hide n show----------------------------//
            //to set the active tab to the color of the login type clicked
          $('#home_click').click(function(){
            $('#home_click').css({'background-color' :'#fff'});
            $('#google_click').css({'background-color' :'#bb2a0b'});
            $('#twitter_click').css({'background-color' :'#53b1f0'});
            $('#facebook_click').css({'background-color' :'#3b5998'});
            $('#linkedin_click').css({'background-color' :'#006695'});
            $('.social-btns a').hide();
          });

        $('#google_click').click(function(){
          $('#google_click').css({'background-color' :'#fff'});
          $('#home_click').css({'color' :'#555555'});
          $('#home_click').css({'background-color' :'#e3e3e3'});
          $('#twitter_click').css({'background-color' :'#53b1f0'});
          $('#facebook_click').css({'background-color' :'#3b5998'});
          $('#linkedin_click').css({'background-color' :'#006695'});
          $('.social-btns a').hide();
          $('.google-btn').show();
        });

        $('#twitter_click').click(function(){
          $('#twitter_click').css({'background-color' :'#fff'});
          $('#home_click').css({'color' :'#555555'});
          $('#home_click').css({'background-color' :'#e3e3e3'});
          $('#facebook_click').css({'background-color' :'#3b5998'});
          $('#google_click').css({'background-color' :'#bb2a0b'});
          $('#linkedin_click').css({'background-color' :'#006695'});
          $('.social-btns a').hide();
          $('.twitter-btn').show();
        });

        $('#facebook_click').click(function(){
          $('#facebook_click').css({'background-color' :'#fff'});
          $('#home_click').css({'color' :'#555555'});
          $('#home_click').css({'background-color' :'#e3e3e3'});
          $('#twitter_click').css({'background-color' :'#53b1f0'});
          $('#google_click').css({'background-color' :'#bb2a0b'});
          $('#linkedin_click').css({'background-color' :'#006695'});
          $('.social-btns a').hide();
          $('.facebook-btn').show();
        });

        $('#linkedin_click').click(function(){
          $('#facebook_click').css({'background-color' :'#3b5998'});
          $('#home_click').css({'color' :'#555555'});
          $('#home_click').css({'background-color' :'#e3e3e3'});
          $('#twitter_click').css({'background-color' :'#53b1f0'});
          $('#google_click').css({'background-color' :'#bb2a0b'});
          $('#linkedin_click').css({'background-color' :'#fff'});
          $('.social-btns a').hide();
          $('.linkedin-btn').show();
        });
      //--------end-of-login-click ------------//
      //---- question js ---------------------//
      //set defalut value for anwer1
                //to set the slider value
                var response_answer1 = $('#response_answer_1').val();

                if($('#response_answer_1').val() == ""){
                    var response_answer1  = 1;
                    $('#response_answer_1').val('1');
                }
                else
                {
                    var response_answer1 = $('#response_answer_1').val();
                }

                var response_answer4 = $('#response_answer_4').val();

                if($('#response_answer_4').val() == ""){
                    var response_answer4  = 1;
                    $('#response_answer_4').val('1');
                }
                else
                {
                    var response_answer4 = $('#response_answer_4').val();
                }

                var response_answer2 = $('#response_answer_2').val();
                //if answer_2 is selected highlight it
                if($('#response_answer_2').val() != ''){
                  $('#option').find('a#'+response_answer2+'').removeClass('btn form priorityTip');
                  $('#option').find('a#'+response_answer2+'').addClass('btn form btn-success priorityTip');
                }

               //hide priority option on load
               if($('#response_answer_2').val() == "add_to_plan"){
                $('#priority_option').show();

                //if answer_3 selected highlight it
                if($('#response_answer_3').val() != ""){
                var response_answer3 = $('#response_answer_3').val();
                $('#priority_option').find('a#'+response_answer3+'').removeClass('btn form priorityTip');
                $('#priority_option').find('a#'+response_answer3+'').addClass('btn form btn-success priorityTip');
                }

               }

               //highlight the section currently on
                var section_id_val = $('#section').val();
                $('#section_'+section_id_val).removeClass($('#section_'+section_id_val).attr('class'));
                $('#section_'+section_id_val).addClass('dropdown on');
                $('#span_'+section_id_val).removeClass($('#span_'+section_id_val).attr('class'));
                $('#span_'+section_id_val).addClass('red');

                if(section_id_val == "1"){
                 $('#section_2').removeClass($('#section_2').attr('class'));
                 $('#section_2').addClass('next');
                 $('#section_3').removeClass($('#section_2').attr('class'));
                 $('#section_3').addClass('next');
                 //for questions count
                 $('#span_2').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_3').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_2').addClass('red');
                 $('#span_3').addClass('red');

                }

                 if(section_id_val == "2"){
                 $('#section_1').removeClass($('#section_1').attr('class'));
                 $('#section_1').addClass('done');
                 $('#section_3').removeClass($('#section_2').attr('class'));
                 $('#section_3').addClass('next');
                 $('#span_1').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_1').addClass('green');
                 //for questions count
                 $('#span_1').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_2').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_3').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_1').addClass('green');
                 $('#span_2').addClass('red');
                 $('#span_3').addClass('red');
                }

               if(section_id_val == "3"){
                 $('#section_1').removeClass($('#section_1').attr('class'));
                 $('#section_1').addClass('done');
                 $('#section_2').removeClass($('#section_2').attr('class'));
                 $('#section_2').addClass('done');
                 $('#span_1').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_2').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_3').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_1').addClass('green');
                 $('#span_2').addClass('green');

                 $('#span_3').addClass('red');
                }

                //post form
                $('#confirm_answer').click(function(e){
                    $('form').submit();
                    return false;
                });

               //For the Add to Plan options
                $('.plan_option').click(function(e){
                    //set the add to plan options
                    $('#response_answer_2').val(e.target.id);
                    //make option as grey


                    $('#option').find('a#in_our_plan').removeClass($('#option').find('a#in_our_plan').
                        attr('class'));
                    $('#option').find('a#add_to_plan').removeClass($('#option').find('a#add_to_plan').
                        attr('class'));
                    $('#option').find('a#not_applicable').removeClass($('#option').find('a#not_applicable').attr('class'));

                    $('#option').find('a#in_our_plan').addClass('btn form priorityTip');
                    $('#option').find('a#add_to_plan').addClass('btn form priorityTip');
                    $('#option').find('a#not_applicable').addClass('btn form priorityTip');

                    //make the selected to green
                    $('#option').find('a#'+e.target.id+'').removeClass('btn form priorityTip');
                    $('#option').find('a#'+e.target.id+'').addClass('btn form btn-success priorityTip');
                    //if Add to Plan is clicked the show the priority tab
                    if(e.target.id == "add_to_plan"){
                      $('#priority_option').slideDown( "fast" );
                    }
                    else{
                      $('#priority_option').slideUp( "fast" );
                    }
                });

                //For the Priority options
                $('.priority_option').click(function(e){

                    $('#response_answer_3').val(e.target.id);

                    //make all option as grey
                    $('#priority_option').find('a#must_do').removeClass($('#option').find('a#must_do').
                        attr('class'));
                    $('#priority_option').find('a#should_do').removeClass($('#option').find('a#should_do').
                        attr('class'));
                    $('#priority_option').find('a#could_do').removeClass($('#option').find('a#could_do').attr('class'));

                    $('#priority_option').find('a#must_do').addClass('btn form priorityTip');
                    $('#priority_option').find('a#should_do').addClass('btn form priorityTip');
                    $('#priority_option').find('a#could_do').addClass('btn form priorityTip');

                    //make selected option as green
                    $('#priority_option').find('a#'+e.target.id+'').removeClass('btn form priorityTip');
                    $('#priority_option').find('a#'+e.target.id+'').addClass('btn form btn-success priorityTip');
                });


                // $(".priorityTip").tooltip({
                //     //placement: 'bottom'
                //     placement: function(tip, element) {
                //   var $element, above, actualHeight, actualWidth, below, boundBottom, boundLeft, boundRight, boundTop, elementAbove, elementBelow, elementLeft, elementRight, isWithinBounds, left, pos, right;
                //   isWithinBounds = function(elementPosition) {
                //     return boundTop < elementPosition.top && boundLeft < elementPosition.left && boundRight > (elementPosition.left + actualWidth) && boundBottom > (elementPosition.top + actualHeight);
                //   };
                //   $element = $(element);
                //   pos = $.extend({}, $element.offset(), {
                //     width: element.offsetWidth,
                //     height: element.offsetHeight
                //   });
                //   actualWidth = 283;
                //   actualHeight = 117;
                //   boundTop = $(document).scrollTop();
                //   boundLeft = $(document).scrollLeft();
                //   boundRight = boundLeft + $(window).width();
                //   boundBottom = boundTop + $(window).height();
                //   elementAbove = {
                //   top: pos.top - actualHeight,
                //   left: pos.left + pos.width / 2 - actualWidth / 2
                //   };
                //   elementBelow = {
                //     top: pos.top + pos.height,
                //     left: pos.left + pos.width / 2 - actualWidth / 2
                //   };
                //   elementLeft = {
                //     top: pos.top + pos.height / 2 - actualHeight / 2,
                //     left: pos.left - actualWidth
                //   };
                //   elementRight = {
                //     top: pos.top + pos.height / 2 - actualHeight / 2,
                //     left: pos.left + pos.width
                //   };
                //   above = isWithinBounds(elementAbove);
                //   below = isWithinBounds(elementBelow);
                //   left = isWithinBounds(elementLeft);
                //   right = isWithinBounds(elementRight);
                //   if (above) {
                //     return "top";
                //   } else {
                //     if (below) {
                //       return "bottom";
                //     } else {
                //       if (left) {
                //         return "left";
                //       } else {
                //         if (right) {
                //           return "right";
                //         } else {
                //           return "right";
                //         }
                //       }
                //     }
                //   }
                // }
                // });


                $( "#slider" ).slider({
                    value:response_answer1,
                    min: 1,
                    max: 5,
                    step: 1,
                    slide: function( event, ui ) {
                        switch(ui.value){
                            case 1 :  $("a.ui-slider-handle").attr('data-original-title', 'We are not engaging in this activity today.'); break;
                            case 2 :  $("a.ui-slider-handle").attr('data-original-title', 'We are inconsistent with our approach and level of activity.'); break;
                            case 3 :  $("a.ui-slider-handle").attr('data-original-title', 'We are currently ad hoc but building this capability.'); break;
                            case 4 :  $("a.ui-slider-handle").attr('data-original-title', 'We do this on a regular basis and differentiate from competitors.'); break;
                            case 5 :  $("a.ui-slider-handle").attr('data-original-title', 'We do this consistently and effectively for market advantage.'); break;
                        }


                    }
                });

                $("#slider").slider({
                   change: function(event, ui) {
                    $( "#response_answer_1" ).val( $( "#slider" ).slider( "value" ));
                }
                });

                $( "#importance-slider" ).slider({
                    value:response_answer4,
                    min: 1,
                    max: 5,
                    step: 1,
                    slide: function( event, ui ) {
                        switch(ui.value){
                            case 1 :  $("a.ui-slider-handle").attr('data-original-title', 'We are not engaging in this activity today.'); break;
                            case 2 :  $("a.ui-slider-handle").attr('data-original-title', 'We are inconsistent with our approach and level of activity.'); break;
                            case 3 :  $("a.ui-slider-handle").attr('data-original-title', 'We are currently ad hoc but building this capability.'); break;
                            case 4 :  $("a.ui-slider-handle").attr('data-original-title', 'We do this on a regular basis and differentiate from competitors.'); break;
                            case 5 :  $("a.ui-slider-handle").attr('data-original-title', 'We do this consistently and effectively for market advantage.'); break;
                        }


                    }
                });

                $("#importance-slider").slider({
                  change: function(event, ui) {
                    $( "#response_answer_4" ).val( $( "#importance-slider" ).slider( "value" ));
                  }
                });

                $('.important-slabels span').click(function(e){
                  console.log($(this).data('value'));
                  $( "#importance-slider" ).slider( "value", $(this).data('value') )
                  $( "#response_answer_4" ).val( $( "#importance-slider" ).slider( "value" ));
                });

                // $("div#slider a.ui-slider-handle").tooltip({
                //     //placement: 'bottom'
                //     placement: function(tip, element) {
                //   var $element, above, actualHeight, actualWidth, below, boundBottom, boundLeft, boundRight, boundTop, elementAbove, elementBelow, elementLeft, elementRight, isWithinBounds, left, pos, right;
                //   isWithinBounds = function(elementPosition) {
                //     return boundTop < elementPosition.top && boundLeft < elementPosition.left && boundRight > (elementPosition.left + actualWidth) && boundBottom > (elementPosition.top + actualHeight);
                //   };
                //   $element = $(element);
                //   pos = $.extend({}, $element.offset(), {
                //     width: element.offsetWidth,
                //     height: element.offsetHeight
                //   });
                //   actualWidth = 283;
                //   actualHeight = 117;
                //   boundTop = $(document).scrollTop();
                //   boundLeft = $(document).scrollLeft();
                //   boundRight = boundLeft + $(window).width();
                //   boundBottom = boundTop + $(window).height();
                //   elementAbove = {
                //   top: pos.top - actualHeight,
                //   left: pos.left + pos.width / 2 - actualWidth / 2
                //   };
                //   elementBelow = {
                //     top: pos.top + pos.height,
                //     left: pos.left + pos.width / 2 - actualWidth / 2
                //   };
                //   elementLeft = {
                //     top: pos.top + pos.height / 2 - actualHeight / 2,
                //     left: pos.left - actualWidth
                //   };
                //   elementRight = {
                //     top: pos.top + pos.height / 2 - actualHeight / 2,
                //     left: pos.left + pos.width
                //   };
                //   above = isWithinBounds(elementAbove);
                //   below = isWithinBounds(elementBelow);
                //   left = isWithinBounds(elementLeft);
                //   right = isWithinBounds(elementRight);
                //   if (above) {
                //     return "top";
                //   } else {
                //     if (below) {
                //       return "bottom";
                //     } else {
                //       if (left) {
                //         return "left";
                //       } else {
                //         if (right) {
                //           return "right";
                //         } else {
                //           return "right";
                //         }
                //       }
                //     }
                //   }
                // }
                // });
                // $("a.ui-slider-handle").attr('data-original-title', 'We are not engaging in this activity today');

                $('.sub-section-name').live('click',function(){
                  $.ajax({
                    url:      '/surveys/sub_section',
                    type:     'get',
                    dataType: 'json',
                    data: "sub_section_name="+$(this).text(),
                    success: function(data){
                      if(data.current_survey!=null) {
                        window.location = '/surveys/'+data.current_survey.id+'/question/'+data.question_id;
                      }
                    },
                    error: function(e){
                    }
                  });
                });

      //------------end of question page js ---- //

            //------------admin user index js -----------//
              $('#company').change(function(){
                var name = "";
                $("#company option:selected").each(function () {
                    name = $(this).text();
                });
                //alert(id);
                $.ajax({
                    url: '/admin/users?company_name='+name,
                    type: "GET"
                });
              });

               $('#company_submit').click(function(){
                var flag = true;
                if($('#company_industry_id').val()=="Select Industry"){
                  $('#industry_error').html('Please select industry');
                  flag =  false;
               }
               else{
                 $('#industry_error').html('');
               }
               if($('#company_name').val()==""){
                  $('#company_name_error').html("Company name can't be blank");
                  flag =  false;
               }
               else{
                 $('#company_name_error').html('');
               }
               if($('#company_website').val()==""){
                  $('#website_error').html("Wesite can't be blank");
                  flag =  false;
               }
               else{
                 $('#website_error').html('');
               }
               return flag;
              });

              $('#survey_submit').live('click', function(){
                var flag = true;
                if($('#survey_size').val()=="Select"){
                  $('#size_error').html('Please select Company Size');
                  flag =  false;
               }
               else{
                 $('#size_error').html('');
               }

               if($('#survey_revenue').val()=="Select"){
                  $('#revenue_error').html('Please select Total Revenue');
                  flag =  false;
               }
               else{
                 $('#revenue_error').html('');
               }
               return flag;
              });


            $('#company_industry_id').change(function(){
                var flag = true;
                if($('#company_industry_id').val()=="Select Industry"){
                  $('#industry_error').html('Please select industry');
                  flag =  false;
               }
               else{
                 $('#industry_error').html('');
               }
               return flag;
              });

               $('#questn_save').click(function(){
                var flag = true;
                if($('#sub_section_id').val()=="Select Section"){
                 $('#section_error').html('Please select Section');
                  flag =  false;
                }else{
                  $('#section_error').html('');
                }
                if($('#question_description').val()==""){
                 $('#description_error').html("Description can't be blank");
                  flag =  false;
                }else{
                  $('#description_error').html('');
                }
                if($('#question_name').val()==""){
                 $('#question_name_error').html("Question can't be blank");
                  flag =  false;
                }else{
                  $('#question_name_error').html('');
                }
                return flag;
              });

              $('#survey_size').change(function(){
                var flag = true;
                if($('#survey_size').val()=="Select"){
                  $('#size_error').html('Please select industry');
                  flag =  false;
               }
               else{
                 $('#size_error').html('');
               }
               return flag;
              });

              $('#survey_revenue').change(function(){
                var flag = true;
                if($('#survey_revenue').val()=="Select"){
                  $('#revenue_error').html('Please select industry');
                  flag =  false;
               }
               else{
                 $('#revenue_error').html('');
               }
               return flag;
              });

              $('#industry').change(function(){
                var id = "";
                $("#industry option:selected").each(function () {
                    id = $(this).val();
                });
                //alert(id);
                $.ajax({
                    url: '/admin/users?industry_id='+id,
                    type: "GET"
                });
              });
           //--------------  end admin_user_index update -----------/

            $(function () {
             $('.tabs').click(function(){
                alert($(this).attr('id'));
             });
            })


      $('#resultTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       //-------report page table ids ------ //
       $('#report_StrategyTable, #report_ProgramTable, #report_SystemTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_add_to_planTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_must_doTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_should_doTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_could_doTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_not_applicableTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

       $('#report_in_planTable').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );



       //---end -- for --- report page table---//
      // -- admin user table id --- //
      $('#user_table').dataTable( {
            "bPaginate": true,
            "bLengthChange": true,
            "bFilter": true,
            "bInfo": false,
            "bAutoWidth": true,
            "aaSorting": [ [8,'desc']],
            "aoColumnDefs": [{ "bVisible": false, "aTargets": [ 8 ] }],
            "aLengthMenu": [[25, 50, -1],[25, 50, "Show all"]]
        } );

      // -- admin question table id --- //
      $('#question_table').dataTable( {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );
      //---end --of admin user page table---//

      $('#subsection_table').dataTable( {
            "bPaginate": true,
            "bLengthChange": false,
            "bFilter": false,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );


      $('#feed_table').dataTable( {
            "bPaginate": true,
            "bLengthChange": false,
            "bFilter": false,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": true
        } );

      /* report Tables */
       $(".pageAccordion").accordion({
      autoHeight: false,
      navigation: true
    });

});
/* ============================================================
 * bootstrap-dropdown.js v2.3.2
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */



!function ($) {

  "use strict"; // jshint ;_;


 /* DROPDOWN CLASS DEFINITION
  * ========================= */

  var toggle = '[data-toggle=dropdown]'
    , Dropdown = function (element) {
        var $el = $(element).on('click.dropdown.data-api', this.toggle)
        $('html').on('click.dropdown.data-api', function () {
          $el.parent().removeClass('open')
        })
      }

  Dropdown.prototype = {

    constructor: Dropdown

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
        if ('ontouchstart' in document.documentElement) {
          // if mobile we we use a backdrop because click events don't delegate
          $('<div class="dropdown-backdrop"/>').insertBefore($(this)).on('click', clearMenus)
        }
        $parent.toggleClass('open')
      }

      $this.focus()

      return false
    }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) {
        if (e.which == 27) $parent.find(toggle).focus()
        return $this.click()
      }

      $items = $('[role=menu] li:not(.divider):visible a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (!~index) index = 0

      $items
        .eq(index)
        .focus()
    }

  }

  function clearMenus() {
    $('.dropdown-backdrop').remove()
    $(toggle).each(function () {
      getParent($(this)).removeClass('open')
    })
  }

  function getParent($this) {
    var selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = selector && $(selector)

    if (!$parent || !$parent.length) $parent = $this.parent()

    return $parent
  }


  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  var old = $.fn.dropdown

  $.fn.dropdown = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('dropdown')
      if (!data) $this.data('dropdown', (data = new Dropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.dropdown.Constructor = Dropdown


 /* DROPDOWN NO CONFLICT
  * ==================== */

  $.fn.dropdown.noConflict = function () {
    $.fn.dropdown = old
    return this
  }


  /* APPLY TO STANDARD DROPDOWN ELEMENTS
   * =================================== */

  $(document)
    .on('click.dropdown.data-api', clearMenus)
    .on('click.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() })
    .on('click.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
    .on('keydown.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)

  $("a[data-toggle='dropdown']").on('click',function () {
    var list = $(this).next('ul');
    if(list.css('display') == 'none'){
      $('.dropdown-menu').hide();
      list.toggle();
    }else{
      $('.dropdown-menu').hide();
    }
  });

}(window.jQuery);
