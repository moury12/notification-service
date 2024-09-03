import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notification_service/notification.dart';

class DownloadContent extends StatefulWidget {
  const DownloadContent({super.key});

  @override
  State<DownloadContent> createState() => _DownloadContentState();
}

class _DownloadContentState extends State<DownloadContent> {
  StreamController<double> downloadController = StreamController<double>();
  DateTime? lastNotificationUpdate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: downloadController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Download failed: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Preparing to download...');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return const Text('Download complete!');
                }
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            '${(snapshot.data! * 100).floor().toString()}%'),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LinearProgressIndicator(
                            value: snapshot.data,
                            minHeight: 10,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const Text('Press the button to start downloading');
              },
            ),
            ElevatedButton(
              onPressed: () {
                downloadContent();
              },
              child: const Text('Download'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> downloadContent() async {
    const directory = '/storage/emulated/0/Download';
    String filePath = '$directory/downloaded_file.mp4';

    await Dio().download(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
      filePath,
      onReceiveProgress: (count, total) {
        if (total != -1) {
          double progress = count / total;
          downloadController.add(progress);
          updateNotification((progress * 100).toInt(), filePath);
        }
      },
    );

    // Add a slight delay to ensure final UI and notification update.
    await Future.delayed(Duration(milliseconds: 100));

    // Ensure final UI and notification update when download is complete.
    downloadController.add(1.0);
    updateNotification(100, filePath);
  }

  @override
  void dispose() {
    downloadController.close();
    super.dispose();
  }

  void updateNotification(int progress, String filePath) {
    final now = DateTime.now();
    if (lastNotificationUpdate == null ||
        now.difference(lastNotificationUpdate!).inMilliseconds >= 100) {
      NotificationService.showDownloadNotification(progress, filePath);
      lastNotificationUpdate = now;
    }
  }
}
