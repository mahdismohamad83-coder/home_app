import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const HomeItemFinderApp());
}

class HomeItemFinderApp extends StatelessWidget {
  const HomeItemFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7A1C3E);
    const backgroundColor = Color(0xFFFAF6F7);

    return MaterialApp(
      title: 'ردیاب هوشمند وسایل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  void _loadAllItems() async {
    final data = await DBHelper.getAllItems();
    setState(() {
      _items = data;
    });
  }

  void _searchItems(String query) async {
    if (query.isEmpty) {
      _loadAllItems();
      return;
    }
    final data = await DBHelper.searchItems(query);
    setState(() {
      _items = data;
    });
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();
    const primaryColor = Color(0xFF7A1C3E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bookmark_add_rounded, color: primaryColor, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'ثبت وسیله جدید در انبار خانه',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'نام وسیله (مثلاً کیف زرشکی)',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined, color: primaryColor),
                  filled: true,
                  fillColor: const Color(0xFFFAF6F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'محل قرارگیری (مثلاً کمد سوم، طبقه دوم)',
                  prefixIcon: const Icon(Icons.place_outlined, color: primaryColor),
                  filled: true,
                  fillColor: const Color(0xFFFAF6F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(
                  labelText: 'توضیحات تکمیلی (مثلاً داخل کیسه سبز رنگ)',
                  prefixIcon: const Icon(Icons.info_outline, color: primaryColor),
                  filled: true,
                  fillColor: const Color(0xFFFAF6F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty) {
                      await DBHelper.insertItem({
                        'name': nameController.text.trim(),
                        'location': locationController.text.trim(),
                        'details': detailsController.text.trim(),
                      });
                      Navigator.pop(ctx);
                      _loadAllItems();
                    }
                  },
                  child: const Text(
                    'ذخیره در حافظه خانه',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7A1C3E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جای وسایل کجاست؟ 🔍'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchItems,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'سرچ کن چی کجاست... (مثلا کیف زرشکی)',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey[400]),
                          const SizedBox(height: 15),
                          Text(
                            'هنوز وسیله‌ای ثبت نکرده‌ای!',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'با دکمه پایین صفحه اولین وسیله رو اضافه کن.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (ctx, index) {
                        final item = _items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.checkroom_rounded, color: primaryColor),
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.place, size: 14, color: primaryColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'مکان: ${item['location']}',
                                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item['details'] != null && item['details'].isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.info, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'جزئیات: ${item['details']}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () async {
                                await DBHelper.deleteItem(item['id']);
                                _loadAllItems();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('افزودن وسیله', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
