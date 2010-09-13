Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({
	'.form_ajax' : Remote.Form({
					onLoading: function(){
    					$('wait').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					},
					onComplete: function(){
    					$('wait').innerHTML='';
  					}
	}),
	'.form_ajax1' : Remote.Form({
					onLoading: function(){
    					$('dest1').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					}
	}),
	'.form_ajax2' : Remote.Form()
});
