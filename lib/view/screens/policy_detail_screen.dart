import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PolicyDetailScreen extends StatelessWidget {
  final String title;
  final String htmlContent;

  const PolicyDetailScreen({
    super.key,
    required this.title,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        title: Text(
          title,
          style: const TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF8F9FE)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: htmlContent.trim().isEmpty
                        ? const Center(
                            child: Text(
                              "No content available.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : HtmlWidget(
                            htmlContent,
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              height: 1.6,
                              color: Color(0xFF334155),
                              fontFamily: 'Inter',
                            ),
                            customStylesBuilder: (element) {
                              if (element.localName == 'h1') {
                                return {
                                  'font-size': '20px',
                                  'font-weight': 'bold',
                                  'color': '#1E293B',
                                  'margin-bottom': '12px',
                                  'margin-top': '8px',
                                };
                              }
                              if (element.localName == 'h2') {
                                return {
                                  'font-size': '17px',
                                  'font-weight': 'bold',
                                  'color': '#334155',
                                  'margin-bottom': '10px',
                                };
                              }
                              if (element.localName == 'p') {
                                return {'margin-bottom': '14px'};
                              }
                              if (element.localName == 'a') {
                                return {
                                  'color': '#4F46E5',
                                  'text-decoration': 'none',
                                  'font-weight': '600',
                                };
                              }
                              return null;
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
