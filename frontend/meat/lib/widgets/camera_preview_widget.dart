import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final Future<void> initializeControllerFuture;

  const CameraPreviewWidget(
      {Key? key,
      required this.controller,
      required this.initializeControllerFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20), //15
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder<void>(
          future: initializeControllerFuture, // 비동기작업 기다리는 대상 객체
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // 비동기작업 완료되면
              // CameraController의 CameraPreview 사용
              return CameraPreview(controller);
            } else {
              // 비동기작업 완료되지 않았으면
              // 즉 CameraPreview 없을 때 로딩 화면
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color.fromARGB(117, 105, 105, 105),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 32, 32, 32)),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
