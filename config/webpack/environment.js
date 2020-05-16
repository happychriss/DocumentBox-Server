const { environment } = require('@rails/webpacker')

// https://stackoverflow.com/questions/57555708/rails-6-how-to-add-jquery-ui-through-webpacker

const webpack = require('webpack')
environment.plugins.prepend('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',

    })
);


module.exports = environment
