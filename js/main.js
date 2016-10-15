(function($) {
	function supportsInputPlaceholder() {
	  var el = document.createElement('input');
	  return 'placeholder' in el;
	}
	$(function() {
		if (!supportsInputPlaceholder()) {
			var searchInput = $('#searchInput'),
				placeholder = searchInput.attr('placeholder');
			searchInput
				.val(placeholder)
				.focus(function() {
					var $this = $(this);
					$this.addClass('touched');
					if ($this.val() === placeholder) {
						$this.val('');
					}
				})
				.blur(function() {
					var $this = $(this);
					$this.removeClass('touched');
					if ($this.val() === '') {
						$this.val(placeholder);
					}
				});
		}
	});
})(jQuery);