import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isDarkMode;

  const PostCard({
    super.key,
    required this.post,
    required this.isDarkMode,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: MediaQuery.of(context).size.width * 1.2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Post Image with GestureDetector
          GestureDetector(
            onDoubleTap: () {
              setState(() => isLiked = true);
              _animationController
                  .forward()
                  .then((_) => _animationController.reverse());
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(widget.post['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Profile Picture Overlay (Rounded Rectangle)
          Positioned(
            top: -15,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  widget.post['userImage'],
                  width: 60,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Vertical Interaction Bar
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      onTap: () => setState(() => isLiked = !isLiked),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      icon: Icons.more_horiz,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Caption Overlay at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 70,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.transparent,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                widget.post['caption'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 24),
    );
  }
}
