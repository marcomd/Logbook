Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({
    'div.ajax div.pagination a' : Remote.Link
    ,
	'.lnk_ajax1' : Remote.Link({
					onLoading: function(){
    					$('wait1').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					},
					onComplete: function(){
    					$('wait1').innerHTML='';
  					}
	}),
	'.lnk_ajax2' : Remote.Link({
					onLoading: function(){
    					$('dest2').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					}
	}),
	'.lnk_ajax3' : Remote.Link({
					onLoading: function(){
    					$('dest3').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					}
	}),
	'.lnk_ajax4' : Remote.Link({
					onLoading: function(){
    					$('dest4').innerHTML='<img src="/images/ajax_loading.gif" border="0" />';
  					}
	})
});

function updajax(dest,address) {
	new Ajax.Updater(
	dest,
	address,
	{
		method: 'get',
		asynchronous:true,
		evalScripts:false,
		onLoading:function(){
			//$(dest).removeClassName('hidden').update('Attendere prego...');
			$(dest).innerHTML='<img src="images/ajax_loading.gif" border="0" />';
		},
		onComplete:function(){
			//$(dest).visualEffect('Grow');
			//new Effect.ScrollTo(dest,{duration:0.5});
		}
        //,
        //parameters:Form.serialize($('new_preventivo'))
	}
	);
	return false;
  }