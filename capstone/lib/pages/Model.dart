import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Model extends StatefulWidget {
  const Model({super.key});

  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> {
  late Object model;
  @override
  void initState() {
    model = Object(fileName: "assets/model/model.obj");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Yash Vardhan"),
      ),
      body: Container(
        child: Cube(
          onSceneCreated: (Scene scene) {
            scene.world.add(model);
          },
        ),
      ),
    );
  }
}
