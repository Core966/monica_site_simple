webshims.polyfill('forms-ext');

$(document).ready(function () {
    $('#feed-form').validate({
        rules: {
	    'feed[title]': {
                required: true,
                pattern: "[\s\u00c0-\u00ffA-Za-z0-9\.,!?]{1,}"
            },
            'feed[content]': {
                required: true,
                pattern: "^[ A-Za-z0-9_?!.,\-\>\<\/[\\]\u00c0-\u00ff]{1,}$"
            }

        },
        messages: {
	    'feed[title]' : '<p class="validation-custom-error">A címben csak betű, szám, pont, vessző, felkiáltójel és kérdőjel lehet, valamint space karakter.</p>',
	    'feed[content]' : '<p class="validation-custom-error">A tartalomban csak betű, szám, pont, vessző, felkiáltójel, kérdőjel, kötőjel és zárójel lehet, valamint space karakter.</p><br/><p class="validation-custom-notification">Ha biztos benne hogy megfelelő adatot írt be, nyomja meg ismét a létrehozás gombot</p>'
        },
        errorPlacement: function(error, $elem) {
            if ($elem.is('textarea')) {
                $elem.next().css('border', '2px solid red').css('border-radius', '4px');
            }
	    if ($elem.is('input')) {
		$elem.css('border', '1px solid red').css('box-shadow', '1px red inset').css('border-radius', '4px');
	    }
            if ($elem.attr('name') == 'feed[content]') {
              error.insertBefore('textarea#feed_content');
            } else {
              error.insertBefore($elem);
            }
        },
        ignore: []
    });
    $('#blog-form').validate({
        rules: {
	    'post[title]': {
                required: true,
                pattern: "[\s\u00c0-\u00ffA-Za-z0-9\.,!?]{1,}"
            },
            'post[body]': {
                required: true,
                pattern: "^[ A-Za-z0-9_?!.,\-\>\<\/[\\]\u00c0-\u00ff]{1,}$"
            }

        },
        messages: {
	    'post[title]' : '<p class="validation-custom-error">A címben csak betű, szám, pont, vessző, felkiáltójel és kérdőjel lehet, valamint space karakter.</p>',
	    'post[body]' : '<p class="validation-custom-error">A tartalomban csak betű, szám, pont, vessző, felkiáltójel, kérdőjel, kötőjel és zárójel lehet, valamint space karakter.</p><br/><p class="validation-custom-notification">Ha biztos benne hogy megfelelő adatot írt be, nyomja meg ismét a létrehozás gombot</p>'
        },
        errorPlacement: function(error, $elem) {
            if ($elem.is('textarea')) {
                $elem.next().css('border', '2px solid red').css('border-radius', '4px');
            }
	    if ($elem.is('input')) {
		$elem.css('border', '1px solid red').css('box-shadow', '1px red inset').css('border-radius', '4px');
	    }
            if ($elem.attr('name') == 'post[body]') {
              error.insertBefore('textarea#post_body');
            } else {
              error.insertBefore($elem);
            }
        },
        ignore: []
    });
});
