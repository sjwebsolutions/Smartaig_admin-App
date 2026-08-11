import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BannerDetailsScreen extends StatefulWidget {
  final String imageUrl;
  final String title;

  const BannerDetailsScreen({super.key, required this.imageUrl, required this.title});

  @override
  State<BannerDetailsScreen> createState() => _BannerDetailsScreenState();
}

class _BannerDetailsScreenState extends State<BannerDetailsScreen> {
  bool _isSharing = false;

  Future<void> _shareImage() async {
    print("🚩 [Share Process Started]");
    print("🔗 Image URL: ${widget.imageUrl}");
    
    setState(() {
      _isSharing = true;
    });

    try {
      print("📥 Downloading image...");
      final response = await http.get(Uri.parse(widget.imageUrl));
      print("📡 Response Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final temp = await getTemporaryDirectory();
        final path = '${temp.path}/banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(path);
        await file.writeAsBytes(bytes);
        print("💾 Image saved locally at: $path");

        print("📤 Opening Share Sheet...");
        await Share.shareXFiles(
          [XFile(path)],
          text: widget.title,
        );
        print("✅ Share Sheet Opened");
      } else {
        print("❌ Failed to download image. Status: ${response.statusCode}");
        Get.snackbar("Error", "Failed to download image for sharing");
      }
    } catch (e) {
      print("❌ Error during sharing: $e");
      Get.snackbar("Error", "An error occurred while sharing: $e");
    } finally {
      setState(() {
        _isSharing = false;
      });
      print("🚩 [Share Process Finished]");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3E9FF),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF0038A8),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF0038A8)));
                    },
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text("Failed to load image", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isSharing)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text("Preparing image...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _shareImage,
              icon: _isSharing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.share_rounded),
              label: Text(_isSharing ? "Sharing..." : "SHARE PHOTO"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0038A8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                shadowColor: const Color(0xFF0038A8).withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
