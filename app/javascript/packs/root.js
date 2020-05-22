$(document).ready(function () {
    $('#payment').click(function () {
        $.ajax({
            type: 'POST',
            url: '/create_session',
            dataType: 'json',
            headers: {
                'X-CSRF-Token': getCsrfToken()
            },
            success: function (data) {
                redirectToCheckout(data)
            }
        })
        return false
    })
})

// https://stripe.com/docs/payments/checkout/connect
function startDirectCharge(data) {
    var stripe = Stripe(process.env['STRIPE_PUBLISHABLE_KEY'], {
        stripeAccount: data.stripe_account_id
    })

    stripe.redirectToCheckout({
        sessionId: data.session_id
    }).then(function (result) {
        // If `redirectToCheckout` fails due to a browser or network
        // error, display the localized error message to your customer
        // using `result.error.message`.
        console.log('result', result)
    })
}

function getCsrfToken() {
    return $('meta[name="csrf-token"]').attr('content');
}
