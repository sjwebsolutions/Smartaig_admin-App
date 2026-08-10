import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/banner_model.dart';
import '../../view_models/getX/banner_controller.dart';

class PublishBannerScreen extends StatefulWidget {
  final BannerModel banner;
  const PublishBannerScreen({super.key, required this.banner});

  @override
  State<PublishBannerScreen> createState() => _PublishBannerScreenState();
}

class _PublishBannerScreenState extends State<PublishBannerScreen> {
  final BannerController controller = Get.find<BannerController>();
  final _formKey = GlobalKey<FormState>();

  late bool _audienceParents;
  late bool _audienceTeachers;
  late String _targetType;
  late TextEditingController _daysController;
  final List<int> _selectedClassIds = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing banner data
    _audienceParents = widget.banner.targetedAudiences.contains('Parents');
    _audienceTeachers = widget.banner.targetedAudiences.contains('Teachers');
    _targetType = widget.banner.targetType.toLowerCase() == 'specific' ? 'specific' : 'all';
    _daysController = TextEditingController(text: widget.banner.displayDays.toString());
    
    if (widget.banner.targetedClassIds.isNotEmpty) {
      _selectedClassIds.addAll(widget.banner.targetedClassIds.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e != 0));
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_audienceParents && !_audienceTeachers) {
      Get.snackbar("Error", "Please select at least one audience", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_targetType == 'specific' && _selectedClassIds.isEmpty) {
      Get.snackbar("Error", "Please select at least one class for specific targeting", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    controller.publishBanner(
      id: widget.banner.id,
      audienceParents: _audienceParents ? 1 : 0,
      audienceTeachers: _audienceTeachers ? 1 : 0,
      targetType: _targetType,
      classIds: _targetType == 'specific' ? _selectedClassIds : null,
      displayDays: int.tryParse(_daysController.text) ?? 0,
    );
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
          title: const Text(
            "PUBLISH SETTINGS",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Preview
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.banner.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.banner.bannerName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                softWrap: true,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Target Audience"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("Parents"),
                      value: _audienceParents,
                      onChanged: (val) => setState(() => _audienceParents = val ?? false),
                      activeColor: const Color(0xFF1E293B),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text("Teachers"),
                      value: _audienceTeachers,
                      onChanged: (val) => setState(() => _audienceTeachers = val ?? false),
                      activeColor: const Color(0xFF1E293B),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Target Type"),
              Column(
                children: [
                  _buildRadioButton("All Students", 'all'),
                  _buildRadioButton("Specific Classes", 'specific'),
                ],
              ),

              if (_targetType == 'specific') ...[
                const SizedBox(height: 16),
                _buildClassSelection(),
              ],

              const SizedBox(height: 24),
              _buildSectionTitle("Display Duration"),
              TextFormField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter number of days", suffix: "Days"),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isPublishing.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isPublishing.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("PUBLISH BANNER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                )),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
    );
  }

  Widget _buildRadioButton(String title, String value) {
    return InkWell(
      onTap: () => setState(() => _targetType = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _targetType,
            onChanged: (val) => setState(() => _targetType = val!),
            activeColor: const Color(0xFF1E293B),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Classes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingClasses.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Wrap(
              spacing: 8,
              children: controller.bannerClasses.map((c) {
                final isSelected = _selectedClassIds.contains(c.id);
                return FilterChip(
                  label: Text(c.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedClassIds.add(c.id);
                      } else {
                        _selectedClassIds.remove(c.id);
                      }
                    });
                  },
                  selectedColor: Colors.blue.withAlpha(40),
                  checkmarkColor: const Color(0xFF1E293B),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B))),
    );
  }
}
