import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF990033)),
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
  String imageBase64;

  ItemModel({
    required this.id,
    required this.name,
    required this.location,
    this.description = '',
    this.imageBase64 = '',
  });

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ItemModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageBase64': imageBase64,
    };
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  User? _currentUser;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fa-IR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakResult(String textToSpeak) async {
    await _flutterTts.speak(textToSpeak);
  }

  // ورود با گوگل
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('با موفقیت با گوگل وارد شدید! ✨')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ورود با گوگل: ${e.toString()}')),
        );
      }
    }
  }

  // ورود با شماره تلفن (ارسال کد OTP)
  void _showPhoneAuthDialog(BuildContext context) {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    String verificationIdReceived = '';
    bool codeSent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('ورود با شماره تلفن 📱', style: TextStyle(color: Color(0xFF990033), fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!codeSent) ...[
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'شماره موبایل (مثلا 09123456789)',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF990033)),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'کد تایید پیامک شده',
                        prefixIcon: Icon(Icons.lock_clock, color: Color(0xFF990033)),
                      ),
                    ),
                  ],
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
                ),
                onPressed: () async {
                  if (!codeSent) {
                    final phone = phoneController.text.trim();
                    if (phone.isEmpty) return;

                    try {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: phone,
                        verificationCompleted: (PhoneAuthCredential credential) async {
                          await FirebaseAuth.instance.signInWithCredential(credential);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ورود موفقیت‌آمیز بود!')));
                          }
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.message}')));
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          verificationIdReceived = verificationId;
                          setDialogState(() {
                            codeSent = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد تایید ارسال شد.')));
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
                    }
                  } else {
                    final smsCode = otpController.text.trim();
                    if (smsCode.isEmpty) return;
                    try {
                      final credential = PhoneAuthProvider.credential(
                        verificationId: verificationIdReceived,
                        smsCode: smsCode,
                      );
                      await FirebaseAuth.instance.signInWithCredential(credential);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('با موفقیت وارد شدید! ✨')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('کد تایید اشتباه است: $e')));
                      }
                    }
                  }
                },
                child: Text(codeSent ? 'تایید کد' : 'ارسال کد'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      _currentUser = null;
    });
  }

  CollectionReference? get _itemsCollection {
    if (_currentUser == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).collection('items');
  }

  void _addItem(String name, String location, String description, String imageBase64) {
    if (_itemsCollection != null) {
      _itemsCollection!.add({
        'name': name,
        'location': location,
        'description': description,
        'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _deleteItem(String id) {
    if (_itemsCollection != null) {
      _itemsCollection!.doc(id).delete();
    }
  }

  void _editItem(String id, String name, String location, String description, String imageBase64) {
    if (_itemsCollection != null) {
      _itemsCollection!.doc(id).update({
        'name': name,
        'location': location,
        'description': description,
        'imageBase64': imageBase64,
      });
    }
  }

  // نمایش جزئیات به همراه عکس بزرگ و خواندن صوتی
  void _showItemDetailsDialog(ItemModel item) {
    // خواندن خودکار صوتی
    _speakResult("${item.name} در ${item.location}");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF990033)),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF990033)),
              onPressed: () => _speakResult("${item.name} در ${item.location}"),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageBase64.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    base64Decode(item.imageBase64),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Text('📍 جایگاه: ${item.location}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF990033))),
              const SizedBox(height: 8),
              Text('📝 توضیحات: ${item.description.isNotEmpty ? item.description : "توضیحاتی ثبت نشده است."}', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990033), foregroundColor: Colors.white),
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
        title: const Text('کجاست؟ 🏡❓', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF990033),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFFFF0F3),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF990033)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF990033)),
              ),
              accountName: Text(_currentUser?.email ?? _currentUser?.phoneNumber ?? 'کاربر مهمان', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(_currentUser != null ? 'فضای ابری فعال است ☁️' : 'وارد شوید'),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF990033)),
              title: const Text('صفحه اصلی'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF990033)),
              title: const Text('لیست تمام وسایل'),
              onTap: () {
                Navigator.pop(context);
                if (_currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ابتدا وارد حساب کاربری شوید.')));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ItemListScreen(
                    itemsStream: _itemsCollection!.orderBy('name').snapshots(),
                    onDelete: _deleteItem,
                    onEdit: _editItem,
                    onAdd: _addItem,
                    onShowDetails: _showItemDetailsDialog,
                  )));
                }
              },
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text('طراح و سازنده:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('mahdis.mohamad83@gmail.com', style: TextStyle(fontSize: 12, color: Color(0xFF990033), fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('تمامی حقوق محفوظ است.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _currentUser == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 70, color: Color(0xFF990033)),
                    const SizedBox(height: 16),
                    const Text('خوش آمدید به برنامه «کجاست؟» 🏡', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF660022)), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('برای ذخیره‌سازی ابری و جستجوی صوتی وسایلتان، لطفاً وارد شوید.', style: TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990033), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      onPressed: () => _signInWithGoogle(context),
                      icon: const Icon(Icons.login),
                      label: const Text('ورود با حساب گوگل ✨'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF990033), side: const BorderSide(color: Color(0xFF990033)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      onPressed: () => _showPhoneAuthDialog(context),
                      icon: const Icon(Icons.phone_android),
                      label: const Text('ورود با شماره تلفن (OTP) 📱'),
                    ),
                  ],
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _itemsCollection?.orderBy('name').snapshots(),
              builder: (context, snapshot) {
                List<ItemModel> items = [];
                if (snapshot.hasData) {
                  items = snapshot.data!.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF990033), Color(0xFFCC3366)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('سلام مهدیس عزیز! فضای ابری شما فعال است ☁️ و آماده جستجوی صوتی و تصویری وسایل.', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 30),
                    const Text('جستجوی هوشمند وسیله 🔍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF660022))),
                    const SizedBox(height: 10),
                    Autocomplete<ItemModel>(
                      displayStringForOption: (ItemModel option) => option.name,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.trim().isEmpty) return const Iterable<ItemModel>.empty();
                        return items.where((item) => item.name.contains(textEditingValue.text) || item.location.contains(textEditingValue.text));
                      },
                      onSelected: (ItemModel selection) {
                        _showItemDetailsDialog(selection);
                      },
                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'مثلا بنویس لباس یا سوئیچ...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF990033)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
                                    title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('جایگاه: ${option.location}'),
                                    leading: option.imageBase64.isNotEmpty
                                        ? CircleAvatar(backgroundImage: MemoryImage(base64Decode(option.imageBase64)))
                                        : const Icon(Icons.image, color: Color(0xFF990033)),
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ItemListScreen(
                          itemsStream: _itemsCollection!.orderBy('name').snapshots(),
                          onDelete: _deleteItem,
                          onEdit: _editItem,
                          onAdd: _addItem,
                          onShowDetails: _showItemDetailsDialog,
                        )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF990033),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('مشاهده لیست کامل وسایل و افزودن جدید 📋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class ItemListScreen extends StatelessWidget {
  final Stream<QuerySnapshot> itemsStream;
  final Function(String) onDelete;
  final Function(String, String, String, String) onEdit;
  final Function(String, String, String, String) onAdd;
  final Function(ItemModel) onShowDetails;

  const ItemListScreen({
    super.key,
    required this.itemsStream,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    required this.onShowDetails,
  });

  void _showAddOrEditDialog(BuildContext context, {ItemModel? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    String imageBase64 = item?.imageBase64 ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(item == null ? 'افزودن وسیله جدید 📸' : 'ویرایش وسیله ✏️'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'نام وسیله')),
                  const SizedBox(height: 10),
                  TextField(controller: locationController, decoration: const InputDecoration(labelText: 'جایگاه نگهداری')),
                  const SizedBox(height: 10),
                  TextField(controller: descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: 'توضیحات تکمیلی')),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                      if (pickedFile != null) {
                        final bytes = await pickedFile.readAsBytes();
                        setDialogState(() {
                          imageBase64 = base64Encode(bytes);
                        });
                      }
                    },
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF990033)),
                    label: Text(imageBase64.isNotEmpty ? 'تصویر ثبت شد (تغییر عکس)' : 'گرفتن عکس وسیله 📷'),
                  ),
                  if (imageBase64.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(base64Decode(imageBase64), height: 100, width: 100, fit: BoxFit.cover),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990033), foregroundColor: Colors.white),
                onPressed: () {
                  if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                    if (item == null) {
                      onAdd(nameController.text, locationController.text, descriptionController.text, imageBase64);
                    } else {
                      onEdit(item.id, nameController.text, locationController.text, descriptionController.text, imageBase64);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('ذخیره'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text('لیست وسایل ابری شخصی', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF990033),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

          if (items.isEmpty) {
            return const Center(child: Text('هنوز هیچ وسیله‌ای ثبت نشده! 🌸', style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  onTap: () => onShowDetails(item),
                  leading: item.imageBase64.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(base64Decode(item.imageBase64), width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : const CircleAvatar(backgroundColor: Color(0xFFFFF0F3), child: Icon(Icons.image, color: Color(0xFF990033))),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('📍 جایگاه: ${item.location}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddOrEditDialog(context, item: item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDelete(item.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF990033),
        foregroundColor: Colors.white,
        onPressed: () => _showAddOrEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
