// define how the server should handle the data when it receives a GET, POST or PATCH request
const express = require('express');
const router = express.Router();
const Product = require('../models/product')

// check if GET, POST OR PATCH, delete request

// get all products
router.get('/', async (req, res) => {
     try {
          const products = await Product.find() // add await keyword before method call, and then assign result to a variable
          // JS runtime will pause your code at this line allowing other code to run in meantime, until async function call has returned its result
          // .find() is a mongoose method
          res.json(products) // send response with data of products in form of JSON
     } catch (err) {
          res.status(500).json({message: err.message})
     }
});

// get one product
router.get('/:id', getProduct, (req, res) => {
     res.json(res.product) // send the user a response in JSON with the res.product that we defined in middleware
     // returns product's specific info
})

// create one product
router.post('/', async (req, res) => { // request and response
     const product = new Product({ // create a variable that will be assigned to a new Product from our model that we create earlier
          name: req.body.name,
          quantity: req.body.quantity
     }) // tell route to save request made by user's input

     try {
          const newProduct = await product.save() 
          // use save instead of find to tell db that we want to hold the info a user passes to us through this router function
          res.status(201).json(newProduct)
     } catch (err) {
          res.status(400).json({ message: err.message}) // if user passes in bad data
     }
})

// update one product
router.patch('/:id', getProduct, async (req, res) => {
     if (req.body.name != null) {
          res.product.name = req.body.name // res.product is returned response value from middleware function
     }
     if (req.body.quantity != null) {
          res.product.quantity = req.body.quantity
     }

     try {
          const updatedProduct = await res.product.save() // take res.product with new name or quantity and save it
          res.json(updatedProduct) // return new updatedProduct object to our user in form of JSON -> so text shows up as JSON on route.rest
     } catch {
          res.status(400).json({ message: err.message })
     }
})

// delete one product
router.delete('/:id', getProduct, async (req, res) => {
     try {
          await res.product.remove() // use remove method to delete product that res.product object was set to
          res.json({ message: 'Deleted this subscriber'})
     } catch (err) {
          res.status(500).json({ message: err.message })
     }
})

// middleware in the Mongoose GET/PATCH/POST statements
// 3 routes requires ID of a specific user, helper function instead of rewriting 3 times
// add middleware function to function declaration of each route above^
// gets /:id needed above
async function getProduct(req, res, next) {
     try {
          product = await Product.findById(req.params.id) // Product model object, and use findById method to find product that correlates to IS user passes in from parent route
          // req.params is user passed parameter
          // req.params will return parameters in the matched route.
          // If your route is /user/:id and you make a request to /user/5
          // req.params would yield {id: "5"}
          if (product == null) {
               return res.status(404).json({ message: 'Cant find subscriber'})
          }
     } catch (err) {
          return res.status(500).json({ message: err.nessage})
     }

     res.product = product
     next() // tells function execution to move onto the next section of our code, i.e rest of route function (actual request)
}

module.exports = router
