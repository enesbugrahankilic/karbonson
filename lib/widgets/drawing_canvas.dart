// lib/widgets/drawing_canvas.dart
// Interactive drawing canvas for custom profile pictures

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

class DrawingCanvas extends StatefulWidget {
  final Color initialColor;
  final double initialBrushSize;
  final Function(ui.Image) onSave;
  final VoidCallback? onClear;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const DrawingCanvas({
    super.key,
    this.initialColor = Colors.black,
    this.initialBrushSize = 5.0,
    required this.onSave,
    this.onClear,
    this.onUndo,
    this.onRedo,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<List<Offset>> _strokes = [];
  final List<List<Offset>> _redoStrokes = [];
  final List<Color> _strokeColors = [];
  final List<double> _strokeSizes = [];
  Color _currentColor = Colors.black;
  double _currentBrushSize = 5.0;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _currentBrushSize = widget.initialBrushSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Canvas Area
          Container(
            height: 300,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onPanStart: _startDrawing,
              onPanUpdate: _updateDrawing,
              onPanEnd: _endDrawing,
              child: CustomPaint(
                painter: DrawingPainter(
                  strokes: _strokes,
                  strokeColors: _strokeColors,
                  strokeSizes: _strokeSizes,
                ),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Color Palette
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorButton(Colors.black),
                    _buildColorButton(Colors.red),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.green),
                    _buildColorButton(Colors.yellow),
                    _buildColorButton(Colors.purple),
                    _buildColorButton(Colors.orange),
                    _buildColorButton(Colors.pink),
                  ],
                ),

                const SizedBox(height: 16),

                // Brush Size Slider
                Row(
                  children: [
                    Text(
                      AppLocalizations.brushSize,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentBrushSize,
                        min: 1.0,
                        max: 20.0,
                        onChanged: (value) {
                          setState(() {
                            _currentBrushSize = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      _currentBrushSize.round().toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.undo,
                      label: AppLocalizations.undo,
                      onPressed: _canUndo ? _undo : null,
                    ),
                    _buildActionButton(
                      icon: Icons.redo,
                      label: AppLocalizations.redo,
                      onPressed: _canRedo ? _redo : null,
                    ),
                    _buildActionButton(
                      icon: Icons.clear,
                      label: AppLocalizations.clear,
                      onPressed: _clearCanvas,
                    ),
                    _buildActionButton(
                      icon: Icons.save,
                      label: AppLocalizations.saveDrawing,
                      onPressed: _saveDrawing,
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color ? Colors.black : Colors.grey.shade300,
            width: _currentColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Theme.of(context).primaryColor : null,
        foregroundColor: isPrimary ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _startDrawing(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _strokes.add([details.localPosition]);
      _strokeColors.add(_currentColor);
      _strokeSizes.add(_currentBrushSize);
      _redoStrokes.clear(); // Clear redo stack when new stroke starts
    });
  }

  void _updateDrawing(DragUpdateDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _strokes.last.add(details.localPosition);
    });
  }

  void _endDrawing(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
    });
  }

  bool get _canUndo => _strokes.isNotEmpty;
  bool get _canRedo => _redoStrokes.isNotEmpty;

  void _undo() {
    if (!_canUndo) return;

    setState(() {
      final lastStroke = _strokes.removeLast();
      final lastColor = _strokeColors.removeLast();
      final lastSize = _strokeSizes.removeLast();

      _redoStrokes.add(lastStroke);
      _strokeColors.add(lastColor); // Add back for redo
      _strokeSizes.add(lastSize);
    });

    widget.onUndo?.call();
  }

  void _redo() {
    if (!_canRedo) return;

    setState(() {
      final stroke = _redoStrokes.removeLast();
      _strokes.add(stroke);
      // Colors and sizes are already in the lists
    });

    widget.onRedo?.call();
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _strokeColors.clear();
      _strokeSizes.clear();
      _redoStrokes.clear();
    });

    widget.onClear?.call();
  }

  Future<void> _saveDrawing() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.drawingSaveFailed)),
      );
      return;
    }

    try {
      // Create a picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Set canvas size
      const size = Size(300, 300);

      // Draw white background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Draw all strokes
      for (int i = 0; i < _strokes.length; i++) {
        final stroke = _strokes[i];
        final color = _strokeColors[i];
        final brushSize = _strokeSizes[i];

        if (stroke.length < 2) continue;

        final path = Path();
        path.moveTo(stroke[0].dx, stroke[0].dy);

        for (int j = 1; j < stroke.length; j++) {
          path.lineTo(stroke[j].dx, stroke[j].dy);
        }

        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = brushSize
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        );
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());

      widget.onSave(image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.drawingSaved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.drawingSaveFailed)),
      );
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Color> strokeColors;
  final List<double> strokeSizes;

  DrawingPainter({
    required this.strokes,
    required this.strokeColors,
    required this.strokeSizes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw all strokes
    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final color = strokeColors[i];
      final brushSize = strokeSizes[i];

      if (stroke.length < 2) {
        // Draw dot for single point
        canvas.drawCircle(
          stroke[0],
          brushSize / 2,
          Paint()..color = color,
        );
        continue;
      }

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int j = 1; j < stroke.length; j++) {
        path.lineTo(stroke[j].dx, stroke[j].dy);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = brushSize
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.strokeColors != strokeColors ||
        oldDelegate.strokeSizes != strokeSizes;
  }
}
