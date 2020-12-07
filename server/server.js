const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const port = 3000;
//const bodyParser = require("body-parser")

app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());
app.use(bodyParser.json());

//import routes
const vendorsRoute = require('./routes/vendors');
app.use('/vendors', vendorsRoute);

//db
async function connectDB(){
    await mongoose.connect("mongodb+srv://testUser:testPass@cluster0.neji0.mongodb.net/test?retryWrites=true&w=majority", { useNewUrlParser: true, useUnifiedTopology: true });
    console.log("db connected");
}
connectDB();

app.get('/', (req, res) => {
  res.send('Hello World!');
})

app.listen(port);