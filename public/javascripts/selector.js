Event.addBehavior({
    // Cliccando sulla riga viene evidenziata
    '.selective:click' : function(e) {
        //$('trl'+this.value).toggleClassName('selected');
        if (this.checked)
            $('tr_'+this.value).addClassName('selected');
        else
            $('tr_'+this.value).removeClassName('selected');
    },
    // Un aiuto per de/selezionare in automatico più righe
    '.select.reverse:click' : function(e) {
            $$('.selective').each(function(e){ if(e.type == 'checkbox') e.click() });
            return false;
    },
    '.select.all:click' : function(e) {
            $$('.selective').each(function(e){
                if(e.type == 'checkbox') {
                    e.checked = 1;
                    $('tr_'+e.value).addClassName('selected');
                }
            });
            return false;
    },
    '.select.none:click' : function(e) {
            $$('.selective').each(function(e){
                if(e.type == 'checkbox') {
                    e.checked = 0;
                    $('tr_'+e.value).removeClassName('selected')
                }
            });
            return false;
    },
    '.select.toggle:click' : function(e) {
            var v = this.checked;
            $$('.selective').each(function(e){
                if(e.type == 'checkbox') {
                    //alert('v:'+v+' ee:'+ee.value);
                    e.checked = v;
                    e.checked ? $('tr_'+e.value).addClassName('selected') : $('tr_'+e.value).removeClassName('selected')
                }
            });
    }
});