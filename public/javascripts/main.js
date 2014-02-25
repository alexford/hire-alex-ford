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
      $("input[name='reservation[token]']").val(token.id);

      $.ajax({
        type: "POST",
        url: '/reserve',
        data: $("form").serialize(),
        success: function(data) {
          debugger;
        },
        error: function(data) {

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