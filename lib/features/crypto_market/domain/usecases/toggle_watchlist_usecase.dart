import '../repositories/crypto_repository.dart';

class ToggleWatchlistUseCase {
  final CryptoRepository repository;

  const ToggleWatchlistUseCase(this.repository);

  Future<bool> call(String coinId) {
    return repository.toggleWatchlist(coinId);
  }
}
