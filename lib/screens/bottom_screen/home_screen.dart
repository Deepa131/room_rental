import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int first = 0;
  int second = 0;
  int result = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child:Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                first = int.parse(value);
              },
              decoration: InputDecoration(
                labelText: "Enter first no",
                hintText: "e.g 12",
                border: OutlineInputBorder(),
              ),
            ),
            //Invisble box
            SizedBox(height: 8),
            TextField(
              // Styling : CSS
              onChanged: (value) {
                second = int.parse(value);
              },
              decoration: InputDecoration(
                labelText: "Enter second no",
                hintText: "e.g 13",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Button
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = first + second;
                  });
                },
                child: Text("Add", style: TextStyle(fontSize: 20)),
              ),
            ),
 
            SizedBox(height: 8),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = first - second;
                  });
                },
                child: Text("Subtract", style: TextStyle(fontSize: 20)),
              ),
            ),
 
            SizedBox(height: 8),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = first * second;
                  });
                },
                child: Text("Multiply", style: TextStyle(fontSize: 20)),
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