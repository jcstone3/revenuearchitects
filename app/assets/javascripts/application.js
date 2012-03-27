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
//= require_tree .

$(document).ready(function(){
  /* Your javascripts goes here... */
  //to hide and show login and signup	

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
                	alert('hi');
					$('#tab-content').css({'background-color' :'#fff'});
					}, function () {
	    			var cssObj = {
	      			'background-color' : '#fff' ,
	      			'color': 'black'   			
	   			 	}
	    			$('#tab-content').css(cssObj);
	 			 	});

				$('#twitter_click').click(function(){		
					$('#tab-content').css({'background-color' :'#53b1f0', 'color': '#fff'});
					}, function () {
	    			var cssObj = {
	      			'background-color' : '#53b1f0', 
	      			'color': '#fff'   			
	   			 	}
	    			$('#tab-content').css(cssObj);
	 			 	});

				$('#facebook_click').click(function(){				
					$('#tab-content').css({'background-color' :'#3b5998', 'color': '#fff'});
					}, function () {
	    			var cssObj = {
	      			'background-color' : '#3b5998', 
	      			'color': '#fff'    			
	   			 	}
	    			$('#tab-content').css(cssObj);
	 			 	});

				$('#google_click').click(function(){				
					$('#tab-content').css({'border' :'#bb2a0b', 'color': '#fff'});
					}, function () {
	    			var cssObj = {
	      			'background-color' : '#bb2a0b', 
	      			'color': '#fff'     			
	   			 	}
	    			$('#tab-content').css(cssObj);
	 			 	});

				$('#linkedin_click').click(function(){				
					$('#tab-content').css({'background-color' :'#006695', 'color': '#fff'});
					}, function () {
	    			var cssObj = {
	      			'background-color' : '#006695',
	      			'color': '#fff'     			
	   			 	}
	    			$('#tab-content').css(cssObj);
	 			 	});
			//--------end-of-login-click ------------//
			//---- question js ---------------------//
			//set defalut value for anwer1 
               $( "#response_answer_1" ).val('1');

               //hide priority option on load
               $('#priority_option').hide();  
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
                 $('#span_2').hide();
                 $('#span_3').hide();
                }

                 if(section_id_val == "2"){
                 $('#section_1').removeClass($('#section_2').attr('class'));
                 $('#section_1').addClass('done'); 
                 $('#section_3').removeClass($('#section_2').attr('class'));
                 $('#section_3').addClass('next');  
                 $('#span_1').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_1').addClass('green');
                 $('#span_3').hide();                
                }

               if(section_id_val == "3"){                
                 $('#section_1').removeClass($('#section_1').attr('class'));
                 $('#section_1').addClass('done'); 
                 $('#section_2').removeClass($('#section_2').attr('class'));
                 $('#section_2').addClass('done');
                 $('#span_1').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_2').removeClass($('#span_'+section_id_val).attr('class'));
                 $('#span_1').addClass('green');
                 $('#span_2').addClass('green');
                 $('#span_3').show();                     
                }

                //post form
                $('#confirm_answer').click(function(e){                   
                    $('form').submit();
                    return false;
                });
               
               //For the Add to Plan options
                $('#option').click(function(e){
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
                      $('#priority_option').show();                      
                    }
                    else{
                      $('#priority_option').hide();  
                    }
                });

                //For the Priority options
                $('#priority_option').click(function(e){
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
               
                
                $(".priorityTip").tooltip({
                    placement: 'bottom' 
                }); 
                
                
                
                $( "#slider" ).slider({
                    value:0,
                    min: 1,
                    max: 5,
                    step: 1,
                    slide: function( event, ui ) {
                        switch(ui.value){
                            case 1 :  $("a.ui-slider-handle").attr('data-original-title', 'Weak'); break;
                            case 2 :  $("a.ui-slider-handle").attr('data-original-title', 'Basic'); break;
                            case 3 :  $("a.ui-slider-handle").attr('data-original-title', 'Developing'); break;
                            case 4 :  $("a.ui-slider-handle").attr('data-original-title', 'Differntiated'); break;
                            case 5 :  $("a.ui-slider-handle").attr('data-original-title', 'World Class'); break;
                        }
  

                    }
                });

                $("#slider").slider({
                   change: function(event, ui) {                    
                    $( "#response_answer_1" ).val( $( "#slider" ).slider( "value" ));
                }
                });
                


                $("div#slider a.ui-slider-handle").tooltip({
                    placement: 'bottom' 
                });
                $("a.ui-slider-handle").attr('data-original-title', 'Please Fill Text 0');


			//------------end of question page js ---- //

      $(function () {
      $('.tabs').click(function(){
          alert($(this).attr('id'));
        });
      })
   
});
