import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareModal extends StatelessWidget {
  final String message;
  final String link;
  final String fullMessage;

  const ShareModal({
    super.key,
    required this.message,
    required this.link,
    required this.fullMessage,
  });

  Future<void> _shareToFacebook(BuildContext context) async {
    final String url =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        await Share.share(fullMessage);
      }
    }
  }

  Future<void> _shareToMessenger(BuildContext context) async {
    final String url = 'https://m.me/share/?link=${Uri.encodeComponent(link)}';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        await Share.share(fullMessage);
      }
    }
  }

  Future<void> _shareToInstagram(BuildContext context) async {
    if (context.mounted) {
      await Share.share(fullMessage);
    }
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: fullMessage));
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link copied!'),
          backgroundColor: Color(0xFF12CDD9),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Color(0xFF1F1D2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share to',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  icon: FontAwesomeIcons.facebook,
                  label: 'Facebook',
                  color: Color(0xFF1877F2),
                  onTap: () => _shareToFacebook(context),
                ),
                _buildShareButton(
                  icon: FontAwesomeIcons.instagram,
                  label: 'Instagram',
                  color: Color(0xFFE4405F),
                  onTap: () => _shareToInstagram(context),
                ),
                _buildShareButton(
                  icon: FontAwesomeIcons.facebookMessenger,
                  label: 'Messenger',
                  color: Color(0xFF00B2FF),
                  onTap: () => _shareToMessenger(context),
                ),
                _buildShareButton(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  color: Color(0xFF12CDD9),
                  onTap: () => _copyLink(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
