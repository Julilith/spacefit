(function(){

  $('input[type=radio]').on('change', function() {
      $(this).closest("form").submit();
  });

  $('input[data-action="submitOnClick"]').on('click', function() {
      $(this).closest("form").submit();
  });

  $(document).ready( function(){
    $('[data-action="submitOnClick"]').on('change', function() {
      $(this).closest("form").submit();
    });
  })

  jQuery.fn.extend({
    submitOnClick: function(sumit_type_){
      sumit_type_= sumit_type_ || 'form'
      $(this).closest(sumit_type_).submit()
    },
  })

})(jQuery);


