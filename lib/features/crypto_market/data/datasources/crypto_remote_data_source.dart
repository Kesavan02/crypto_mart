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

  @override
  Future<List<CoinModel>> getCoins({
    String? search,
    String? sortBy,
    String? order,
  }) async {
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
        return list.map((json) => CoinModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw AppException(
          message: 'Failed to fetch coins from server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred while fetching coins',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    try {
      final response = await client.get(ApiEndpoints.coinDetail(coinId));

      if (response.statusCode == 200) {
        return CoinDetailModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw AppException(
          message: 'Failed to fetch coin detail for $coinId',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred while fetching coin details',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<List<ChartPointModel>> getCoinChart(
    String coinId, {
    int days = 7,
  }) async {
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
        message: e.message ?? 'Network error occurred while fetching chart points',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<MarketStatsModel> getMarketStats() async {
    try {
      final response = await client.get(ApiEndpoints.marketStats);

      if (response.statusCode == 200) {
        return MarketStatsModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw AppException(
          message: 'Failed to fetch market stats',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Network error occurred while fetching market stats',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: e.toString());
    }
  }
}
