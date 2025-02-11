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
      margin: const EdgeInsets.only(bottom: 16),
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

          // Like Animation Overlay
          Center(
            child: ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withAlpha(128),
                size: 100,
              ),
            ),
          ),

          // Profile Picture Overlay
          Positioned(
            top: -20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(widget.post['userImage']),
              ),
            ),
          ),

          // Top Info Overlay
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.post['likes']} • ${widget.post['timeAgo']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Bottom Controls and Caption Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(128),
                    Colors.transparent,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        onTap: () => setState(() => isLiked = !isLiked),
                      ),
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        onTap: () {},
                      ),
                      _buildActionButton(
                        icon: Icons.more_horiz,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post['caption'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
