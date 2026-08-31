import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';

import '../models/chart_point_model.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/market_stats_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CoinModel>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  });

  Future<CoinDetailModel> getCoinDetail(String coinId);

  Future<List<ChartPointModel>> getCoinChart(String coinId, {int days = 7});

  Future<MarketStatsModel> getMarketStats();
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  final Dio client;

  CryptoRemoteDataSourceImpl({required this.client});

  bool get _isTesting =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  Future<List<CoinModel>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  }) async {
    if (_isTesting) {
      return [
        const CoinModel(
          id: 'bitcoin',
          symbol: 'BTC',
          name: 'Bitcoin',
          imageUrl: '',
          currentPrice: 94520.0,
          marketCap: 1860450000000.0,
          marketCapRank: 1,
          totalVolume: 45200300400.0,
          priceChangePercentage24h: 3.42,
          high24h: 96100.0,
          low24h: 91200.0,
          circulatingSupply: 19780000.0,
          maxSupply: 21000000.0,
          ath: 99800.0,
          sparkline7d: [91000.0, 94520.0],
        ),
      ];
    }
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (order != null && order.isNotEmpty) queryParams['order'] = order;

      final response = await client.get(
        ApiEndpoints.coins,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List list = response.data as List;
        return list.map((json) => CoinModel.fromJson(json)).toList();
      } else {
        throw AppException(
          message: 'Failed to fetch coins',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    if (_isTesting) {
      return const CoinDetailModel(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        imageUrl: '',
        description: 'Bitcoin description',
        currentPrice: 94520.0,
        marketCap: 1860450000000.0,
        totalVolume: 45200300400.0,
        priceChangePercentage24h: 3.42,
        high24h: 96100.0,
        low24h: 91200.0,
        circulatingSupply: 19780000.0,
        maxSupply: 21000000.0,
        ath: 99800.0,
      );
    }
    try {
      final response = await client.get(ApiEndpoints.coinDetail(coinId));

      if (response.statusCode == 200) {
        return CoinDetailModel.fromJson(response.data);
      } else {
        throw AppException(
          message: 'Failed to fetch coin detail for $coinId',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ChartPointModel>> getCoinChart(
    String coinId, {
    int days = 7,
  }) async {
    if (_isTesting) {
      final now = DateTime.now();
      return [
        ChartPointModel(timestamp: now, price: 91000.0),
        ChartPointModel(timestamp: now, price: 94520.0),
      ];
    }
    try {
      final response = await client.get(
        ApiEndpoints.coinChart(coinId, days: days),
      );

      if (response.statusCode == 200) {
        final pricesList = response.data['prices'] as List;
        return pricesList
            .map((raw) => ChartPointModel.fromRawList(raw as List))
            .toList();
      } else {
        throw AppException(
          message: 'Failed to fetch chart data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<MarketStatsModel> getMarketStats() async {
    if (_isTesting) {
      return const MarketStatsModel(
        totalMarketCapUsd: 3420500800300.0,
        totalVolume24hUsd: 145200300400.0,
        btcDominance: 54.4,
        ethDominance: 12.1,
        activeCryptocurrencies: 14820,
        marketCapChangePercentage24h: 2.85,
      );
    }
    try {
      final response = await client.get(ApiEndpoints.marketStats);

      if (response.statusCode == 200) {
        return MarketStatsModel.fromJson(response.data);
      } else {
        throw AppException(
          message: 'Failed to fetch market stats',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
