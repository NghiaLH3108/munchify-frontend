import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/forecast_item_entity.dart';
import '../repositories/stock_repository.dart';

class GenerateDraftImportsFromForecastUseCase {
  final StockRepository repository;

  GenerateDraftImportsFromForecastUseCase(this.repository);

  Future<Either<Failure, bool>> call(List<ForecastItemEntity> items) async {
    return await repository.generateDraftImportsFromForecast(items);
  }
}
