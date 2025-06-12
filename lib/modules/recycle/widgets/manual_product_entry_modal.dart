import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';

class ManualProductEntryModal extends StatefulWidget {
  final String barcode;
  final Function(String title, String brand) onSubmit;
  final VoidCallback onCancel;

  const ManualProductEntryModal({
    super.key,
    required this.barcode,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<ManualProductEntryModal> createState() => _ManualProductEntryModalState();

  static Future<void> show({
    required BuildContext context,
    required String barcode,
    required Function(String title, String brand) onSubmit,
    required VoidCallback onCancel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: ManualProductEntryModal(
            barcode: barcode,
            onSubmit: onSubmit,
            onCancel: onCancel,
          ),
        );
      },
    );
  }
}

class _ManualProductEntryModalState extends State<ManualProductEntryModal> with SingleTickerProviderStateMixin {
  final titleController = TextEditingController();
  final brandController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _brandFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    // Add listeners to focus nodes to scroll to the focused field
    _titleFocus.addListener(_handleFocusChange);
    _brandFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_titleFocus.hasFocus) {
      _scrollToField(0);
    } else if (_brandFocus.hasFocus) {
      _scrollToField(1);
    }
  }

  void _scrollToField(int fieldIndex) {
    // Add a small delay to ensure the keyboard is shown before scrolling
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      // Scroll to different positions based on which field is focused
      double offset = fieldIndex == 0 ? 150.0 : 220.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    brandController.dispose();
    _animationController.dispose();
    _titleFocus.removeListener(_handleFocusChange);
    _brandFocus.removeListener(_handleFocusChange);
    _titleFocus.dispose();
    _brandFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = titleController.text.trim();
    final brand = brandController.text.trim();
    
    if (title.isEmpty || brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in both title and brand'),
          backgroundColor: CustomTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    Navigator.of(context).pop();
    widget.onSubmit(title, brand);
  }

  void _unfocusAll() {
    _titleFocus.unfocus();
    _brandFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate a reasonable max height for the modal
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _unfocusAll,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          decoration: BoxDecoration(
            color: CustomTheme.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient - not scrollable
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            color: CustomTheme.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Product Not Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Help us improve our search by providing additional product details.',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomTheme.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content - scrollable
              Flexible(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  shrinkWrap: true,
                  children: [
                    // Barcode info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomTheme.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CustomTheme.lightBlueAccent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.qr_code, color: CustomTheme.mediumBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scanned Barcode',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: CustomTheme.darkBlue1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.barcode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CustomTheme.darkBlue1,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title field
                    _buildInputField(
                      label: 'Product Title',
                      hint: 'e.g., Coca-Cola 500ml',
                      controller: titleController,
                      icon: Icons.shopping_bag_outlined,
                      focusNode: _titleFocus,
                      nextFocusNode: _brandFocus,
                    ),
                    const SizedBox(height: 16),
                    
                    // Brand field
                    _buildInputField(
                      label: 'Brand',
                      hint: 'e.g., Coca-Cola',
                      controller: brandController,
                      icon: Icons.business_outlined,
                      focusNode: _brandFocus,
                      isLastField: true,
                    ),
                    
                    // Add extra space at the bottom for keyboard
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 200 : 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading ? null : widget.onCancel,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: CustomTheme.grey200),
                              ),
                              backgroundColor: CustomTheme.white,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: CustomTheme.grey600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: CustomTheme.primaryGreen,
                              foregroundColor: CustomTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.white),
                                  ),
                                )
                              : const Text(
                                  'Search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isLastField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CustomTheme.grey800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CustomTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CustomTheme.grey200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: CustomTheme.grey400,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: CustomTheme.grey600, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.words,
            enabled: !isLoading,
            style: const TextStyle(
              fontSize: 16,
              color: CustomTheme.black87,
            ),
            textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
            onSubmitted: (_) {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            },
          ),
        ),
      ],
    );
  }
}
