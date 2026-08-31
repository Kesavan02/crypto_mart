const express = require('express');
const cryptoController = require('../controllers/cryptoController');

const router = express.Router();

router.get('/coins', (req, res, next) => cryptoController.getCoins(req, res, next));
router.get('/coins/:id', (req, res, next) => cryptoController.getCoinDetail(req, res, next));
router.get('/coins/:id/chart', (req, res, next) => cryptoController.getCoinChart(req, res, next));
router.get('/market/stats', (req, res, next) => cryptoController.getMarketStats(req, res, next));

module.exports = router;
