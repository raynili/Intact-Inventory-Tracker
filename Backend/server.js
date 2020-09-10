require('dotenv').config()

const express = require('express')
const app = express()
const mongoose = require('mongoose')

mongoose.connect(process.env.DATABASE_URL, { useNewUrlParser: true, useUnifiedTopology: true})
const db = mongoose.connection // syntactically easier to reference our database
db.on('error', (error) => console.error(error))
db.once('open', () => console.log('Connected to Database'))

app.use(express.json()) // Tell express that it should accept JSON as the data format
                        // .use is middleware that allows you to run code when the server gets a request but before it gets passed to your routes

// tell server that it now has routes that it needs to handle and use
const productsRouter = require('./routes/products')
app.use('/products', productsRouter)

app.listen(3000, () => console.log('Server Started'))

// start server - npm run devStart
// stop server - control + C
