// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
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

      $(function () {
      $('.tabs').click(function(){
          alert($(this).attr('id'));
        });
      })
   
});
