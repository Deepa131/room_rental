import 'package:flutter/material.dart';
 
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
 
  @override
  State<CartScreen> createState() => _CartScreenState();
}
 
class _CartScreenState extends State<CartScreen> {
  double principle = 0;
  double rate = 0;
  double time = 0;
  double result = 0;
 
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              SizedBox(height: 18),
              TextField(
                onChanged: (value) {
                  principle = double.parse(value);
                },
                decoration: InputDecoration(
                  labelText: "Enter Principle amount",
                  hintText: "e.g 12000",
                  border: OutlineInputBorder(),
                ),
              ),
 
              SizedBox(height: 8),
 
              TextField(
                onChanged: (value) {
                  rate = double.parse(value);
                },
                decoration: InputDecoration(
                  labelText: "Enter Rate",
                  hintText: "e.g 0.05",
                  border: OutlineInputBorder(),
                ),
              ),
 
              SizedBox(height: 8),
 
              TextField(
                onChanged: (value) {
                  time = double.parse(value);
                },
                decoration: InputDecoration(
                  labelText: "Enter Time",
                  hintText: "e.g 2",
                  border: OutlineInputBorder(),
                ),
              ),
 
              SizedBox(height: 18),
 
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      result = (principle * time * rate) / 100;
                    });
                  },
                  child: Text("Calculate", style: TextStyle(fontSize: 20)),
                ),
              ),
 
              SizedBox(height: 8),
              Text("Result is : $result", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}