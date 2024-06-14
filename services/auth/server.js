require('dotenv').config();
const express = require('express');
const app = express();
const userRoutes = require('./routes/userRoutes');

app.use(express.json());
app.use('/api', userRoutes);

app.use(function(req, res, next) {
    const name = process.env.name;
    let message = `Sorry, we cannot find that! Could you please try again or contact ${name}?`;
    res.status(404).send(message);
  });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
