import '../../../../core/errors/failures.dart';
import '../entities/coin_detail_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinDetailUseCase {
  final CryptoRepository repository;

  const GetCoinDetailUseCase(this.repository);

  Future<({Failure? failure, CoinDetailEntity? coinDetail})> call(
    String coinId,
  ) {
    return repository.getCoinDetail(coinId);
  }
}
