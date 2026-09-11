import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class SyllabusAttachmentViewer extends StatefulWidget {
  final String url;
  final String title;
  final bool isImage;

  const SyllabusAttachmentViewer({
    super.key,
    required this.url,
    required this.title,
    required this.isImage,
  });

  @override
  State<SyllabusAttachmentViewer> createState() => _SyllabusAttachmentViewerState();
}

class _SyllabusAttachmentViewerState extends State<SyllabusAttachmentViewer> {
  String? localPath;
  bool isLoading = true;
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  Future<void> _prepareFile() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final extension = widget.isImage ? 'jpg' : 'pdf';
      final path = '${temp.path}/syllabus_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final file = File(path);
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        setState(() {
          localPath = path;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error preparing file: $e");
      if (mounted) {
        Get.snackbar("Error", "Could not load attachment");
        Get.back();
      }
    }
  }

  Future<void> _shareFile() async {
    if (localPath == null) return;
    setState(() => isSharing = true);
    try {
      await Share.shareXFiles([XFile(localPath!)], text: widget.title);
    } catch (e) {
      Get.snackbar("Error", "Could not share file");
    } finally {
      if (mounted) setState(() => isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0038A8)),
                  SizedBox(height: 16),
                  Text("Loading content...", style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: widget.isImage
                          ? InteractiveViewer(
                              child: Image.file(File(localPath!)),
                            )
                          : PDFView(
                              filePath: localPath!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: false,
                              pageFling: false,
                              onError: (error) => debugPrint(error.toString()),
                              onPageError: (page, error) => debugPrint('$page: ${error.toString()}'),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSharing ? null : _shareFile,
                      icon: isSharing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.share_rounded),
                      label: Text(isSharing ? "Sharing..." : "SHARE FILE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0038A8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
