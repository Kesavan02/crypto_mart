import '../../../../core/errors/failures.dart';
import '../entities/coin_entity.dart';
import '../repositories/crypto_repository.dart';

class GetCoinsUseCase {
  final CryptoRepository repository;

  const GetCoinsUseCase(this.repository);

  Future<({Failure? failure, List<CoinEntity>? coins})> call({
    String? search,
    String? sortBy,
    String? order,
  }) {
    return repository.getCoins(
      search: search,
      sortBy: sortBy,
      order: order,
    );
  }
}
