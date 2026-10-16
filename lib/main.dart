import 'package:flutter/material.dart';

void main() {
  runApp(const KojasApp());
}

class KojasApp extends StatelessWidget {
  const KojasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کجاست؟',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF990033),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F3),
      ),
      home: const MainScreen(),
    );
  }
}

class ItemModel {
  String id;
  String name;
  String location;

  ItemModel({required this.id, required this.name, required this.location});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<ItemModel> _items = [
    ItemModel(id: '1', name: 'لباس مجلسی', location: 'کمد اتاق خواب'),
    ItemModel(id: '2', name: 'لباس ورزشی', location: 'کشوی دوم دراور'),
    ItemModel(id: '3', name: 'سوئیچ ماشین', location: 'روی میز جاکفشی'),
    ItemModel(id: '4', name: 'کارت ملی', location: 'کیف چرمی قهوه‌ای'),
  ];

  void _addItem(String name, String location) {
    setState(() {
      _items.add(ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        location: location,
      ));
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  void _editItem(String id, String newName, String newLocation) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index].name = newName;
        _items[index].location = newLocation;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text(
          'کجاست؟ 🏡❓',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF990033),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF990033), Color(0xFFCC3366)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'وسایلت کجاست؟ گم شدی؟ 🤔',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'به راحتی پیداشون کن و جای همه‌چیز رو یادت بمونه!',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'جستجوی سریع وسیله 🔍',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF660022)),
              ),
              const SizedBox(height: 10),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _items
                      .map((e) => e.name)
                      .where((name) => name.contains(textEditingValue.text));
                },
                onSelected: (String selection) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('انتخاب شد: $selection')),
                  );
                },
                fieldViewBuilder:
                    (context, textController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'مثلا بنویس لباس یا سوئیچ...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF990033)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFFCD5CE)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemListScreen(
                        items: _items,
                        onDelete: _deleteItem,
                        onEdit: _editItem,
                        onAdd: _addItem,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990033),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.list_alt_rounded, size: 26),
                label: const Text(
                  'برای دیدن لیست وسایل ضربه بزنید 📋',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  final List<ItemModel> items;
  final Function(String) onDelete;
  final Function(String, String, String) onEdit;
  final Function(String, String) onAdd;

  const ItemListScreen({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  void _showAddOrEditDialog({ItemModel? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'افزودن وسیله جدید ✨' : 'ویرایش وسیله ✏️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'نام وسیله'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'جایگاه نگهداری'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF990033),
                foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty) {
                if (item == null) {
                  widget.onAdd(nameController.text, locationController.text);
                } else {
                  widget.onEdit(
                      item.id, nameController.text, locationController.text);
                }
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text('لیست وسایل ثبت‌شده',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF990033),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.items.isEmpty
          ? const Center(
              child: Text('هنوز هیچ وسیله‌ای ثبت نشده! 🌸',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('جایگاه: ${item.location}',
                        style: const TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddOrEditDialog(item: item),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            widget.onDelete(item.id);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF990033),
        foregroundColor: Colors.white,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
