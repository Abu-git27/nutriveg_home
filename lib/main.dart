import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'screens/add_purchase_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('purchases');

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

      total += double.tryParse(
        item['price'].toString(),
      ) ??
          0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F4),
      appBar: AppBar(
        title: const Text(
          'NutriVeg Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('purchases').listenable(),
        builder: (context, Box box, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Good Morning 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                    const Expanded(
                      child: DashboardCard(
                        title: "Health Score",
                        value: "0",
                        icon: Icons.favorite,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Expanded(
                      child: DashboardCard(
                        title: "Current Stock",
                        value: "0",
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
                          builder: (_) => const AddPurchaseScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Purchase"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.restaurant),
                    label: const Text("Record Consumption"),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            Icon(icon, size: 35),
            SizedBox(height: 10),

            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('purchases');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchases"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
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

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final item = box.getAt(index);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: Text(item['vegetable']),
                  subtitle: Text(
                    "${item['quantity']} ${item['unit']}",
                  ),
                  trailing: Text(
                    "₹${item['price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "No Stock Available",
          style: TextStyle(fontSize: 22),
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "No Reports Generated",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}