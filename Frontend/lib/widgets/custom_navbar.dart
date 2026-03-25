import 'package:flutter/material.dart';
import 'package:trust_guard/utils/app_theme.dart';

class CustomNavbar extends StatelessWidget {
  final Function(int) onNavigate;
  final int currentIndex;

  const CustomNavbar({
    super.key,
    required this.onNavigate,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Area
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Trust",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextSpan(
                      text: "Guard",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Navigation Links (Desktop - Centered)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavItem(
                    title: "Home",
                    isActive: currentIndex == 0,
                    onTap: () => onNavigate(0),
                  ),
                  const SizedBox(width: 40),
                  _NavItem(
                    title: "Detect",
                    isActive: currentIndex == 1,
                    onTap: () => onNavigate(1),
                  ),
                  const SizedBox(width: 40),
                  _NavItem(
                    title: "History",
                    isActive: currentIndex == 2,
                    onTap: () => onNavigate(2),
                  ),
                ],
              ),
            ),

          // Action Button
          ElevatedButton(
            onPressed: () => onNavigate(1), // Go to Analyzer
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Scan Now",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool active = widget.isActive || isHovered;
    return InkWell(
      onTap: widget.onTap,
      onHover: (value) => setState(() => isHovered = value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: active ? AppTheme.primaryColor : Colors.white60,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: active ? 20 : 0,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
