import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/forecast_item_entity.dart';
import '../repositories/stock_repository.dart';

class GetForecastingUseCase {
  final StockRepository repository;

  GetForecastingUseCase(this.repository);

  Future<Either<Failure, List<ForecastItemEntity>>> call({int daysHistory = 30}) async {
    return await repository.getForecasting(daysHistory: daysHistory);
  }
}
