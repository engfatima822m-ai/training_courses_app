import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color appBarColor;
  final double maxWidth;
  final bool showAppBar;
  final bool centerContent;
  final bool enableScroll;
  final EdgeInsets? padding;

  const ResponsivePage({
    super.key,
    required this.child,
    this.title,
    this.floatingActionButton,
    this.actions,
    this.backgroundColor = const Color(0xFFF6F2FA),
    this.appBarColor = const Color(0xFF111111),
    this.maxWidth = 1200,
    this.showAppBar = true,
    this.centerContent = true,
    this.enableScroll = true,
    this.padding,
  });

  double _horizontalPadding(double width) {
    if (width < 380) return 10;
    if (width < 600) return 14;
    if (width < 900) return 18;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: showAppBar
            ? AppBar(
                backgroundColor: appBarColor,
                foregroundColor: Colors.white,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  title ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: actions,
              )
            : null,
        floatingActionButton: floatingActionButton,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = padding?.horizontal == null
                ? _horizontalPadding(constraints.maxWidth)
                : padding!.horizontal / 2;

            final pagePadding = padding ??
                EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 16,
                );

            final content = Padding(
              padding: pagePadding,
              child: Align(
                alignment:
                    centerContent ? Alignment.topCenter : Alignment.topRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
            );

            if (!enableScroll) {
              return content;
            }

            return SingleChildScrollView(
              child: content,
            );
          },
        ),
      ),
    );
  }
}