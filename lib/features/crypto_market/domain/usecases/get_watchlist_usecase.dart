import '../repositories/crypto_repository.dart';

class GetWatchlistUseCase {
  final CryptoRepository repository;

  const GetWatchlistUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getWatchlistIds();
  }
}
