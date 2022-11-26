import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Model extends StatefulWidget {
  const Model({super.key});

  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> with TickerProviderStateMixin {
  Object? model;
  late AnimationController animation;
  late AnimationController animation2;
  late Scene scene;
  int i = 1;
  void _onSceneCreated(Scene pass_scene) {
    scene = pass_scene;
    model = Object(fileName: "assets/model2/model.obj");
    if (model != null) {
      model!.position.setValues(0, -0.5, 0);
      model!.rotation.setValues(0, 180, 0);
      model!.updateTransform();
    }

    scene.world.add(model!);
    scene.camera.zoom = 8;
  }

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this)
      ..addListener(() {
        if (model != null) {
          model!.rotation.setValues(0, 180, 0);
          model!.rotation.y = (animation.value * 20) + 170;
          model!.rotation.x = (animation.value * -10) + 5;
          model!.updateTransform();
          scene.update();
        }
      })
      ..repeat(reverse: true);
    // animation2 = AnimationController(
    //     duration: const Duration(milliseconds: 3000), vsync: this)
    //   ..addListener(() {
    //     if (model != null) {
    //       model!.rotation.setValues(0, 180, 0);
    //       model!.rotation.x = (animation.value * 20);
    //       print(model!.rotation.x);
    //       model!.updateTransform();
    //       scene.update();
    //     }
    //   })
    //   ..repeat(reverse: true);
  }

  @override
  void dispose() {
    animation.dispose();
    animation2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: _onSceneCreated,
    );
  }
}
