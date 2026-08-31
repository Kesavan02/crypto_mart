import '../../domain/entities/chart_point_entity.dart';

class ChartPointModel extends ChartPointEntity {
  const ChartPointModel({
    required super.timestamp,
    required super.price,
  });

  factory ChartPointModel.fromRawList(List<dynamic> list) {
    final rawTimestamp = (list[0] as num).toInt();
    final rawPrice = (list[1] as num).toDouble();
    return ChartPointModel(
      timestamp: DateTime.fromMillisecondsSinceEpoch(rawTimestamp),
      price: rawPrice,
    );
  }
}
