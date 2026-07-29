const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/authMiddleware');
const {
  createTicket,
  getTickets,
  getTicketById,
  updateTicket,
  deleteTicket
} = require('../controllers/ticketController');

router.route('/')
  .post(authMiddleware, createTicket)
  .get(authMiddleware, getTickets);

router.route('/:id')
  .get(authMiddleware, getTicketById)
  .put(authMiddleware, updateTicket)
  .delete(authMiddleware, deleteTicket);

module.exports = router;
