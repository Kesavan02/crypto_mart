import '../../../../core/errors/result.dart';
import '../entities/coin_detail_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinDetailUseCase {
  final CryptoRepository repository;

  const GetCoinDetailUseCase(this.repository);

  Future<Result<CoinDetailEntity>> call(String coinId) {
    return repository.getCoinDetail(coinId);
  }
}
