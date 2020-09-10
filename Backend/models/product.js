// A schema
const mongoose = require('mongoose') // use mongoose's schema models

// create javascript object, with keys for properties of product
// tell database what to expect from each key, inclu. type, if required and if default value should be applied
const productSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    },
    receivedDate: {
        type: Date,
        required: true,
        default: Date.now
    }
})

// allow us to use and interact with database using our schema
module.exports = mongoose.model('Product', productSchema)
// Product is name for model in db
// productSchema is schema that corresponds with model

// now we have a model set up with a schema

