import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyToClipboardWidget extends StatefulWidget {
  final String textToCopy;
  final Widget child;
  final String? successMessage;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  const CopyToClipboardWidget({
    super.key,
    required this.textToCopy,
    required this.child,
    this.successMessage,
    this.icon = Icons.copy,
    this.iconSize = 16,
    this.iconColor,
  });

  @override
  State<CopyToClipboardWidget> createState() => _CopyToClipboardWidgetState();
}

class _CopyToClipboardWidgetState extends State<CopyToClipboardWidget> {
  bool _isHovered = false;

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.textToCopy));
      
      if (widget.successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kopyalama başarısız oldu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copyToClipboard,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _isHovered 
              ? (widget.iconColor ?? Colors.blue).withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: widget.child),
            const SizedBox(width: 8),
            Icon(
              widget.icon,
              size: widget.iconSize,
              color: _isHovered 
                  ? (widget.iconColor ?? Colors.blue)
                  : Colors.grey[600],
            ),
          ],
        ),
      ),
      onHover: (hover) {
        setState(() {
          _isHovered = hover;
        });
      },
    );
  }
}