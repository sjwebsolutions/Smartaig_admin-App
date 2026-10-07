import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class InvoiceViewScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const InvoiceViewScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String? _errorMessage;
  bool _isSharing = false;

  Future<void> _shareFile() async {
    if (widget.filePath.isEmpty) return;
    setState(() => _isSharing = true);
    try {
      await Share.shareXFiles([XFile(widget.filePath)], text: widget.title);
    } catch (e) {
      CustomSnackBar.showError("Error", "Could not share PDF: $e");
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
          leading: const CustomBackButton(),
          title: Text(
            widget.title.toUpperCase(),
            style: AppColors.appBarTitleStyle,
          ),
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
                    icon: _isSharing
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
                    onPressed: _isSharing ? null : _shareFile,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Current page / status pill
            if (_isReady && _totalPages > 0)
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

            // Main PDF Card container
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Stack(
                  children: [
                    if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.redAccent,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Failed to load PDF",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      PDFView(
                        filePath: widget.filePath,
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
                              _isReady = true;
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
                        onError: (error) {
                          debugPrint("PDF Error: ${error.toString()}");
                          if (mounted) {
                            setState(() {
                              _errorMessage = error.toString();
                              _isReady = true;
                            });
                          }
                        },
                        onPageError: (page, error) {
                          debugPrint("PDF Page Error $page: ${error.toString()}");
                        },
                      ),

                    // Loading indicator
                    if (!_isReady && _errorMessage == null)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF0038A8),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Loading document...",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareFile,
                  icon: _isSharing
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
                    _isSharing ? "SHARING..." : "SHARE PDF DOCUMENT",
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
