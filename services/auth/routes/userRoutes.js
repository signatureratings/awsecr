const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');

const usersFilePath = path.join(__dirname, '../users.json');

// Get all users
router.get('/users', (req, res) => {
  fs.readFile(usersFilePath, 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading users file');
    }
    const users = JSON.parse(data);
    res.json(users);
  });
});

// Get user by ID
router.get('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id, 10);
  fs.readFile(usersFilePath, 'utf8', (err, data) => {
    if (err) {
      return res.status(500).send('Error reading users file');
    }
    const users = JSON.parse(data);
    const user = users.find(u => u.id === userId);
    if (!user) {
      return res.status(404).send('User not found');
    }
    res.json(user);
  });
});

module.exports = router;
