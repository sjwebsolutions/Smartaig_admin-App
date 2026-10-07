import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

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
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isPdfReady = false;

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
        CustomSnackBar.showError("Error", "Could not load attachment");
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
      CustomSnackBar.showError("Error", "Could not share file");
    } finally {
      if (mounted) setState(() => isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.screenDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: AppColors.appBarToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: AppColors.appBarCenterTitle,
          title: Text(
            widget.title,
            style: AppColors.appBarTitleStyle,
          ),
          leading: const CustomBackButton(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0038A8),
                            ),
                          )
                        : const Icon(
                            Icons.share_rounded,
                            color: Color(0xFF1E293B),
                            size: 18,
                          ),
                    onPressed: isSharing ? null : _shareFile,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0038A8)),
                    SizedBox(height: 16),
                    Text(
                      "Loading attachment...",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  if (!widget.isImage && _isPdfReady && _totalPages > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 15,
                                  color: Color(0xFF0038A8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Page ${_currentPage + 1} of $_totalPages",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0038A8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFF64748B)),
                                SizedBox(width: 4),
                                Text(
                                  "Scroll to view",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: AppColors.cardBorderRadius,
                        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.isImage
                          ? Image.network(
                              widget.url,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Color(0xFF0038A8)),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text("Failed to load image preview"),
                              ),
                            )
                          : Stack(
                              children: [
                                PDFView(
                                  filePath: localPath,
                                  enableSwipe: true,
                                  swipeHorizontal: false,
                                  autoSpacing: true,
                                  pageFling: true,
                                  pageSnap: true,
                                  fitPolicy: FitPolicy.BOTH,
                                  nightMode: false,
                                  onRender: (pages) {
                                    if (mounted) {
                                      setState(() {
                                        _totalPages = pages ?? 0;
                                        _isPdfReady = true;
                                      });
                                    }
                                  },
                                  onPageChanged: (page, total) {
                                    if (mounted) {
                                      setState(() {
                                        _currentPage = page ?? 0;
                                        _totalPages = total ?? _totalPages;
                                      });
                                    }
                                  },
                                  onError: (error) => Center(child: Text("Error: $error")),
                                  onPageError: (page, error) =>
                                      Center(child: Text('$page: ${error.toString()}')),
                                ),
                                if (!_isPdfReady)
                                  Container(
                                    color: Colors.white,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0038A8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSharing ? null : _shareFile,
                        icon: isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 20),
                        label: Text(
                          isSharing ? "SHARING..." : "SHARE FILE",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.buttonTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: AppColors.buttonShape,
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
