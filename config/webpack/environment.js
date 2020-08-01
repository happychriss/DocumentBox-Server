const { environment } = require('@rails/webpacker')

// https://stackoverflow.com/questions/57555708/rails-6-how-to-add-jquery-ui-through-webpacker

const webpack = require('webpack')
environment.plugins.prepend('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        JQuery: 'jquery',
        jQuery: 'jquery'
    })
);

const aliasConfig = {
    'jquery': 'jquery-ui-dist/external/jquery/jquery',
    'jquery-ui': 'jquery-ui-dist/jquery-ui'
};

environment.config.set('resolve.alias', aliasConfig);

module.exports = environment
