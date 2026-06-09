import 'package:flutter/material.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {

  final formKey = GlobalKey<FormState>();

  final vegetableController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  String selectedUnit = "Kg";

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
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: selectedUnit,
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
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Purchase Saved Successfully",
                      ),
                    ),
                  );
                },

                child: const Text("Save Purchase"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}