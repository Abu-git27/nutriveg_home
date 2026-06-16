import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'screens/add_purchase_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('purchases');
  await Hive.openBox('consumptions');

  runApp(const NutriVegHomeApp());
}

class NutriVegHomeApp extends StatelessWidget {
  const NutriVegHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriVeg Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
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
  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(),
    PurchaseScreen(),
    InventoryScreen(),
    RecipeScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Purchases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Recipes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  double getTotalExpense() {
    final box = Hive.box('purchases');

    double total = 0;

    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);

      total +=
          double.tryParse(item['price'].toString()) ?? 0;
    }

    return total;
  }

  int getHealthScore() {
    final box = Hive.box('purchases');

    Set<String> vegetables = {};

    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);

      vegetables.add(
        item['vegetable']
            .toString()
            .toLowerCase(),
      );
    }

    int count = vegetables.length;

    if (count >= 5) return 100;

    return count * 20;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F4),
      appBar: AppBar(
        title: const Text(
          'NutriVeg Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable:
        Hive.box('purchases').listenable(),
        builder: (context, Box box, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🥕 Welcome to NutriVeg Home",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Track your vegetables smartly",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: "Total Expense",
                        value:
                        "₹${getTotalExpense().toStringAsFixed(0)}",
                        icon: Icons.currency_rupee,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: DashboardCard(
                        title: "Health Score",
                        value:
                        "${getHealthScore()}",
                        icon: Icons.favorite,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: "Current Stock",
                        value: "${box.length}",
                        icon: Icons.inventory,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: DashboardCard(
                        title: "Recipes",
                        value: "0",
                        icon: Icons.restaurant_menu,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const AddPurchaseScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label:
                    const Text("Add Purchase"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.restaurant,
                    ),
                    label: const Text(
                      "Record Consumption",
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  Color getCardColor() {
    switch (title) {
      case "Total Expense":
        return Colors.green;

      case "Current Stock":
        return Colors.orange;

      case "Health Score":
        return Colors.red;

      case "Recipes":
        return Colors.purple;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getCardColor().withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: getCardColor(),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController searchController =
  TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('purchases');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchases"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search Vegetable...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Purchases Yet",
                      style: TextStyle(fontSize: 22),
                    ),
                  );
                }

                List<dynamic> filteredItems = [];

                for (int i = 0; i < box.length; i++) {
                  final item = box.getAt(i);

                  if (item['vegetable']
                      .toString()
                      .toLowerCase()
                      .contains(searchText)) {
                    filteredItems.add({
                      'index': i,
                      'data': item,
                    });
                  }
                }

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching vegetables found",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, position) {
                    final item =
                    filteredItems[position]['data'];

                    final originalIndex =
                    filteredItems[position]['index'];

                    String purchaseDate = "";

                    if (item['date'] != null) {
                      try {
                        final date =
                        DateTime.parse(item['date']);

                        purchaseDate =
                        "${date.day}-${date.month}-${date.year}";
                      } catch (e) {
                        purchaseDate = "";
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: const Text(
                                    "Delete Purchase",
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete this purchase?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                      child:
                                      const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        box.deleteAt(
                                          originalIndex,
                                        );
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                      child:
                                      const Text("Delete"),
                                    ),
                                  ],
                                ),
                          );
                        },

                        leading: const Icon(
                          Icons.shopping_cart,
                        ),

                        title: Text(
                          item['vegetable'],
                        ),

                        subtitle: Text(
                          "${item['quantity']} ${item['unit']} • ₹${item['rate']}/Kg\n$purchaseDate",
                        ),

                        trailing: Text(
                          "₹${item['price']}",
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  String getVegetableEmoji(String vegetable) {
    switch (vegetable.toLowerCase()) {
      case "carrot":
        return "🥕";

      case "onion":
        return "🧅";

      case "tomato":
        return "🍅";

      case "potato":
        return "🥔";

      case "cabbage":
        return "🥬";

      case "chilli":
        return "🌶️";

      case "brinjal":
        return "🍆";

      case "corn":
        return "🌽";

      default:
        return "🥗";
    }
  }

  Color getVegetableColor(String vegetable) {
    switch (vegetable.toLowerCase()) {
      case "carrot":
        return Colors.orange.shade100;

      case "onion":
        return Colors.purple.shade100;

      case "tomato":
        return Colors.red.shade100;

      case "potato":
        return Colors.brown.shade100;

      case "cabbage":
        return Colors.green.shade100;

      case "chilli":
        return Colors.red.shade50;

      case "brinjal":
        return Colors.deepPurple.shade100;

      case "corn":
        return Colors.yellow.shade100;

      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('purchases');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No Stock Available",
                style: TextStyle(fontSize: 22),
              ),
            );
          }

          Map<String, double> inventory = {};
          Map<String, double> inventoryValue = {};

          for (int i = 0; i < box.length; i++) {
            final item = box.getAt(i);

            String vegetable = item['vegetable'];

            double quantity =
                double.tryParse(item['quantity'].toString()) ?? 0;

            double price =
                double.tryParse(item['price'].toString()) ?? 0;

            inventory[vegetable] =
                (inventory[vegetable] ?? 0) + quantity;

            inventoryValue[vegetable] =
                (inventoryValue[vegetable] ?? 0) + price;
          }

          final vegetables = inventory.keys.toList();

          return ListView.builder(
            itemCount: vegetables.length,
            itemBuilder: (context, index) {
              final vegetable = vegetables[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: getVegetableColor(vegetable),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Text(
                      getVegetableEmoji(vegetable),
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    title: Text(
                      vegetable,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      "${inventory[vegetable]} Kg\n"
                          "Value: ₹${inventoryValue[vegetable]!.toStringAsFixed(0)}",
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "No Recipes Found",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('purchases');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F4),
      appBar: AppBar(
        title: const Text("📊 Reports"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          int totalPurchases = box.length;

          double totalExpense = 0;

          Set<String> vegetables = {};

          for (int i = 0; i < box.length; i++) {
            final item = box.getAt(i);

            totalExpense +=
                double.tryParse(item['price'].toString()) ?? 0;

            vegetables.add(
              item['vegetable'].toString().toLowerCase(),
            );
          }

          double averageExpense =
          totalPurchases > 0
              ? totalExpense / totalPurchases
              : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(
                      child: _reportCard(
                        "🛒",
                        "Purchases",
                        "$totalPurchases",
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _reportCard(
                        "🥕",
                        "Vegetables",
                        "${vegetables.length}",
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _reportCard(
                        "💰",
                        "Expense",
                        "₹${totalExpense.toStringAsFixed(0)}",
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _reportCard(
                        "📈",
                        "Average",
                        "₹${averageExpense.toStringAsFixed(0)}",
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.insights,
                          size: 50,
                          color: Colors.green,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "NutriVeg Insights",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Track your vegetable purchases, inventory and health habits smarter every day.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _reportCard(
      String emoji,
      String title,
      String value,
      Color color,
      ) {
    return Card(
      color: color.withOpacity(0.15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 35),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}