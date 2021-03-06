// hirealexford.com JS

$(function() {

  var tokenHandler = StripeCheckout.configure({
    key: bootstrap.stripe_key,
    name: 'Alex Ford',
    description: 'One hour consulting block',
    panelLabel: 'Reserve for {{amount}}',

    amount: 10000,
    image: '/images/headshot.jpg',

    token: function(token, args) {
      $("section#form").hide();
      $("section.status#reserving").show();

      $("input[name='reservation[token]']").val(token.id);

      $.ajax({
        type: "POST",
        url: '/reserve',
        data: $("form").serialize(),
        success: function(data) {
          $("section.status").hide();
          $("section.status#success").show();

          // track conversion on Google
          _gaq.push(['_trackEvent', 'reservation', 'made', '', '100']);
        },
        error: function(data) {
          $("section.status").hide();
          $("section.status#error").show();
        },
        dataType: 'JSON'
      });
    }
  });

  $('form').submit(function(e) {
    e.preventDefault();

    tokenHandler.open({
      email: $("input[name='reservation[email]']").val()
    });
  });

});