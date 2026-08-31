import 'package:equatable/equatable.dart';

class ChartPointEntity extends Equatable {
  final DateTime timestamp;
  final double price;

  const ChartPointEntity({
    required this.timestamp,
    required this.price,
  });

  @override
  List<Object?> get props => [timestamp, price];
}
