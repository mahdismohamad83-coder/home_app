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
  String description;

  ItemModel({
    required this.id,
    required this.name,
    required this.location,
    this.description = '',
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<ItemModel> _items = [
    ItemModel(
      id: '1',
      name: 'لباس مجلسی',
      location: 'کمد اتاق خواب',
      description: 'پیراهن مشکی بلند همراه با کاور',
    ),
    ItemModel(
      id: '2',
      name: 'لباس ورزشی',
      location: 'کشوی دوم دراور',
      description: 'ست طوسی و گرمکن',
    ),
    ItemModel(
      id: '3',
      name: 'سوئیچ ماشین',
      location: 'روی میز جاکفشی',
      description: 'کلید یدک هم داخل کشو هست',
    ),
    ItemModel(
      id: '4',
      name: 'کارت ملی',
      location: 'کیف چرمی قهوه‌ای',
      description: 'طبقه بالای کمد جاکفشی',
    ),
  ];

  void _addItem(String name, String location, String description) {
    setState(() {
      _items.add(ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        location: location,
        description: description,
      ));
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
  }

  void _editItem(String id, String newName, String newLocation, String newDescription) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index].name = newName;
        _items[index].location = newLocation;
        _items[index].description = newDescription;
      }
    });
  }

  void _showItemDetailsDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF990033)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📍 جایگاه: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF990033))),
                Expanded(child: Text(item.location, style: const TextStyle(fontSize: 15))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📝 توضیحات: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF990033))),
                Expanded(
                  child: Text(
                    item.description.isNotEmpty ? item.description : 'توضیحاتی ثبت نشده است.',
                    style: TextStyle(
                      fontSize: 14,
                      color: item.description.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF990033),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
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
              Autocomplete<ItemModel>(
                displayStringForOption: (ItemModel option) => option.name,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.trim().isEmpty) {
                    return const Iterable<ItemModel>.empty();
                  }
                  return _items.where((item) =>
                      item.name.contains(textEditingValue.text) ||
                      item.location.contains(textEditingValue.text));
                },
                onSelected: (ItemModel selection) {
                  _showItemDetailsDialog(selection);
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
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        color: Colors.white,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ItemModel option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('جایگاه: ${option.location}'),
                              leading: const Icon(Icons.search, color: Color(0xFF990033)),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
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
                        onShowDetails: _showItemDetailsDialog,
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
  final Function(String, String, String, String) onEdit;
  final Function(String, String, String) onAdd;
  final Function(ItemModel) onShowDetails;

  const ItemListScreen({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    required this.onShowDetails,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  void _showAddOrEditDialog({ItemModel? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item == null ? 'افزودن وسیله جدید ✨' : 'ویرایش وسیله ✏️'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'نام وسیله',
                  hintText: 'مثلاً: کارت ملی',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'جایگاه نگهداری',
                  hintText: 'مثلاً: کشوی اول میز',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'توضیحات تکمیلی (اختیاری)',
                  hintText: 'مثلاً: رنگش قرمزه، داخل کیف چرمیه',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF990033),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                if (item == null) {
                  widget.onAdd(
                    nameController.text,
                    locationController.text,
                    descriptionController.text,
                  );
                } else {
                  widget.onEdit(
                    item.id,
                    nameController.text,
                    locationController.text,
                    descriptionController.text,
                  );
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
        title: const Text('لیست وسایل ثبت‌شده', style: TextStyle(color: Colors.white)),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => widget.onShowDetails(item),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('📍 جایگاه: ${item.location}',
                            style: const TextStyle(color: Colors.black87)),
                        if (item.description.isNotEmpty)
                          Text('📝 توضیحات: ${item.description}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddOrEditDialog(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
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
