import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddConsumptionScreen extends StatefulWidget {
  const AddConsumptionScreen({super.key});

  @override
  State<AddConsumptionScreen> createState() =>
      _AddConsumptionScreenState();
}

class _AddConsumptionScreenState
    extends State<AddConsumptionScreen> {
  final quantityController =
  TextEditingController();

  String? selectedVegetable;

  @override
  Widget build(BuildContext context) {
    final purchaseBox = Hive.box('purchases');
    final consumptionBox = Hive.box('consumptions');

    final vegetables = purchaseBox.values
        .map((e) => e['vegetable'].toString())
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Record Consumption",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedVegetable,
              decoration: const InputDecoration(
                labelText: "Vegetable",
                border: OutlineInputBorder(),
              ),
              items: vegetables.map((veg) {
                return DropdownMenuItem(
                  value: veg,
                  child: Text(veg),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVegetable = value;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              keyboardType:
              TextInputType.number,
              decoration:
              const InputDecoration(
                labelText:
                "Consumed Quantity (Kg)",
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.restaurant,
                ),
                label: const Text(
                  "Save Consumption",
                ),
                onPressed: () {
                  if (selectedVegetable ==
                      null ||
                      quantityController
                          .text.isEmpty) {
                    return;
                  }

                  consumptionBox.add({
                    'vegetable':
                    selectedVegetable,
                    'quantity':
                    quantityController
                        .text,
                    'date': DateTime.now()
                        .toString(),
                  });

                  ScaffoldMessenger.of(
                      context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Consumption Saved",
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}