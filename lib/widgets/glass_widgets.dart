import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double blurStrength;
  final Border? border;

  const GlassCard({super.key, required this.child, this.padding, this.borderRadius = 16, this.backgroundColor, this.gradient, this.blurStrength = 20, this.border});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: gradient,
            color: backgroundColor ?? AppColors.white10,
            border: border ?? Border.all(color: AppColors.white15, width: 1),
            boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 32, offset: Offset(0, 8))],
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool active;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width, height;
  final Gradient? gradient;

  const NeuButton({super.key, required this.child, this.onTap, this.active = false, this.padding, this.borderRadius = 14, this.width, this.height, this.gradient});

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.96).animate(_c);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) { _c.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          width: widget.width, height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: widget.gradient ?? (widget.active ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.deep]) : null),
            color: (widget.gradient == null && !widget.active) ? AppColors.white10 : null,
            border: Border.all(color: widget.active ? Colors.transparent : AppColors.white15),
            boxShadow: widget.active
                ? [const BoxShadow(color: Color(0x664FACB8), blurRadius: 15, offset: Offset(0, 4))]
                : [const BoxShadow(color: Color(0x4D000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: widget.child,
        ),
      ),
    );
  }
}

class GlassChip extends StatelessWidget {
  final String label; final Color color;
  const GlassChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3), width: 0.5)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    );
  }
}

class PillBadge extends StatelessWidget {
  final String label; final Color bgColor, textColor; final double fontSize;
  const PillBadge({super.key, required this.label, required this.bgColor, required this.textColor, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}

class MoodArrow extends StatelessWidget {
  final String before, after;
  const MoodArrow({super.key, required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      PillBadge(label: before, bgColor: AppColors.coral.withOpacity(0.2), textColor: AppColors.coral),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, color: AppColors.white50, size: 14)),
      PillBadge(label: after, bgColor: AppColors.secondary.withOpacity(0.2), textColor: AppColors.secondary),
    ]);
  }
}

class StarRating extends StatelessWidget {
  final double rating; final double size;
  const StarRating({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, color: AppColors.gold, size: size),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontSize: size - 2, fontWeight: FontWeight.w700)),
    ]);
  }
}

class AmbientBlob extends StatelessWidget {
  final Alignment alignment; final Color color; final double size;
  const AmbientBlob({super.key, required this.alignment, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(0.15), Colors.transparent])),
      ),
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final double width, height; final double borderRadius;
  const SkeletonLoader({super.key, required this.width, required this.height, this.borderRadius = 8});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _a = Tween<double>(begin: 0.04, end: 0.12).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.borderRadius), color: Colors.white.withOpacity(_a.value)),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(color: AppColors.primary, fontSize: 13))),
    ]);
  }
}
