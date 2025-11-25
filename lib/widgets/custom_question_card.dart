import 'package:flutter/material.dart';
import 'package:animations/animations.dart' show PageTransitionSwitcher, SharedAxisTransition, SharedAxisTransitionType;

class CustomQuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final bool isAnswered;
  final String selectedAnswer;
  final String correctAnswer;

  const CustomQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.isAnswered,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
              ),
              const SizedBox(height: 24),
              ...options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: isAnswered ? null : () => onOptionSelected(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(option, context),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Color? _getButtonColor(String option, BuildContext context) {
    if (!isAnswered) return null;
    if (option == correctAnswer) return Theme.of(context).colorScheme.primaryContainer;
    if (option == selectedAnswer && selectedAnswer != correctAnswer) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    return null;
  }
}