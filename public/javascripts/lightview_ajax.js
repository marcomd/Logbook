document.observe('dom:loaded', function() {
 $('lnk_ajax').observe('click', showAjaxForm);
});

function showAjaxForm(event) {
 Event.stop(event);
 Lightview.show({
     //href: url,
     rel: 'ajax',
     options: {
     autosize: true,
     topclose: true,
     ajax: {
         onComplete: function(){
             // once the request is complete we observe the form for a submit
             $('ajaxForm').observe('submit', submitAjaxForm);
         }
     }
 }
 });
}

function submitAjaxForm(event) {
 // block default form submit
 Event.stop(event);

 // if there's no text in the box, don't do anything
 var text = $('ajaxForm').down('input').value.strip();
 if (!text) return;

 Lightview.show({
     //href: url,
     rel: 'ajax',
     options: {
     title: 'results',
     menubar: false,
     topclose: true,
     autosize: true,
     ajax: {
        parameters: Form.serialize('ajaxForm') // the parameters from the form
     }
 }
 });
}