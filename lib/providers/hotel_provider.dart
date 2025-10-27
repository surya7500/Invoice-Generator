import 'package:flutter/foundation.dart';
import '../models/hotel_details.dart';
import '../database/database_helper.dart';

class HotelProvider with ChangeNotifier {
  HotelDetails? _hotelDetails;

  HotelProvider() {
    Future.microtask(() => loadHotelDetails());
  }

  HotelDetails? get hotelDetails => _hotelDetails;

  Future<void> loadHotelDetails() async {
    _hotelDetails = await DatabaseHelper().getHotelDetails();
    notifyListeners();
  }

  Future<void> updateHotelDetails(HotelDetails hotel) async {
    await DatabaseHelper().updateHotelDetails(hotel);
    await loadHotelDetails();
  }
}
