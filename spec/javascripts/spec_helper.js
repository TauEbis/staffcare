//=require jquery
//=require knockout-3.2.0

//=require support/expect
//=require support/sinon
//=require support/chai

// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/bind-poly
//
// Deferring execution
// If you're using CommonJS, RequireJS or some other asynchronous library you can defer execution. Call
// Teaspoon.execute() after everything has been loaded. Simple example of a timeout:
//
// Teaspoon.defer = true
// setTimeout(Teaspoon.execute, 1000)
//
// Matching files
// By default Teaspoon will look for files that match _spec.{js,js.coffee,.coffee}. Add a filename_spec.js file in your
// spec path and it'll be included in the default suite automatically. If you want to customize suites, check out the
// configuration in config/initializers/teaspoon.rb
//
// Manifest
// If you'd rather require your spec files manually (to control order for instance) you can disable the suite matcher in
// the configuration and use this file as a manifest.
//
// For more information: http://github.com/modeset/teaspoon
//
// Chai
// If you're using Chai, you'll probably want to initialize your preferred assertion style. You can read more about Chai
// at: http://chaijs.com/guide/styles
//
// window.assert = chai.assert;
// window.expect = chai.expect;
// window.should = chai.should();
