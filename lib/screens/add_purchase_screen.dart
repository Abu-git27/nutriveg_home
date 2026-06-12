import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final formKey = GlobalKey<FormState>();

  final vegetableController = TextEditingController();
  final quantityController = TextEditingController();
  final rateController = TextEditingController();

  String selectedUnit = "Kg";

  double getTotalPrice() {
    double quantity =
        double.tryParse(quantityController.text) ?? 0;

    double rate =
        double.tryParse(rateController.text) ?? 0;

    return quantity * rate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Purchase"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: vegetableController,
                decoration: const InputDecoration(
                  labelText: "Vegetable Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedUnit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Kg",
                    child: Text("Kg"),
                  ),
                  DropdownMenuItem(
                    value: "Gram",
                    child: Text("Gram"),
                  ),
                  DropdownMenuItem(
                    value: "Piece",
                    child: Text("Piece"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Rate Per Kg",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 15),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Total Price: ₹${getTotalPrice().toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  final box = Hive.box('purchases');

                  double totalPrice = getTotalPrice();

                  box.add({
                    'vegetable': vegetableController.text,
                    'quantity': quantityController.text,
                    'unit': selectedUnit,
                    'rate': rateController.text,
                    'price': totalPrice,
                    'date': DateTime.now().toString(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Purchase Saved Successfully",
                      ),
                    ),
                  );

                  vegetableController.clear();
                  quantityController.clear();
                  rateController.clear();

                  setState(() {});
                },
                child: const Text("Save Purchase"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    vegetableController.dispose();
    quantityController.dispose();
    rateController.dispose();
    super.dispose();
  }
}