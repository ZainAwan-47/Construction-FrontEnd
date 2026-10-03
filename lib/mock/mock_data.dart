// Placeholder for mock data mimicking the prototype
class MockData {
  static const Map<String, dynamic> projectData = {
    'name': 'Gulshan Villa',
    'address': '123 Main St, Karachi',
    'totalBudget': 5000000.0,
    'cashInHand': 1200000.0,
  };

  static const List<Map<String, dynamic>> expenses = [
    {
      'id': 1,
      'category': 'Steel',
      'item': 'Steel Bars',
      'amount': 120000.0,
      'status': 'pending',
    },
    {
      'id': 2,
      'category': 'Cement',
      'item': 'Cement',
      'amount': 50000.0,
      'status': 'approved',
    }
  ];
}