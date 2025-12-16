import '../database/db_helper.dart';

class ProductService {
  final db = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    return await db.getProducts();
  }
}
