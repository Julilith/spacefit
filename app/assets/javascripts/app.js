$(function(){

  $('.list-group-item').on('click', '.btn', function() {
    if ($(this).hasClass('btn-on')) {

      $(this).closest('.list-group-item').next('.sublist-group-item').slideDown();
    } else if ($(this).hasClass('btn-off')) {
      $(this).closest('.list-group-item').next('.sublist-group-item').slideUp();
    }
  });

  $('.like-video-btn').on('click', function() {
    $(this).toggleClass('fa-heart-o fa-heart');
    $(this).closest("form").submit();
  });


$('input[type=radio]').on('change', function() {
    $(this).closest("form").submit();
});

$('select').on('change', function() {
    $(this).closest("form").submit();
});

$('i[data-action="submitOnClick"]').on('click', function() {
    $(this).closest("form").submit();
});


});


