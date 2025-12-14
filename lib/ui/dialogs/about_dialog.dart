import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/juice_theme.dart';
import '../shared/dialog_components.dart';

/// Dialog displaying information about Juice Oracle and the app.
class AboutJuiceDialog extends StatelessWidget {
  const AboutJuiceDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.local_drink,
            color: JuiceTheme.juiceOrange,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'About Juice',
            style: TextStyle(
              fontFamily: JuiceTheme.fontFamilySerif,
              color: JuiceTheme.parchment,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // What is Juice?
              const SectionHeader(
                icon: Icons.help_outline,
                title: 'What is Juice?',
                color: JuiceTheme.gold,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JuiceTheme.ink30,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: JuiceTheme.parchmentDark20,
                  ),
                ),
                child: Text(
                  'Juice is a solo roleplaying oracle designed to be travel-friendly and minimal, yet versatile and complete. '
                  'It is a dense collection of generic tables that can be used to enhance your roleplaying experience.\n\n'
                  'There is a large focus on immersion and NPC interaction, as these are often the most enjoyable parts of a solo session.\n\n'
                  'If you are familiar with the Mythic system, this oracle will feel intuitive. It provides alternative variations of major Mythic components such as Fate Checks, Meaning Tables, Random Events, and Scene Transitions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: JuiceTheme.parchment90,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Juice Oracle Creator
              const SectionHeader(
                icon: Icons.person,
                title: 'Juice Oracle Creator',
                color: JuiceTheme.juiceOrange,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JuiceTheme.juiceOrange08,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: JuiceTheme.juiceOrange25,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: JuiceTheme.juiceOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'thunder9861',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: JuiceTheme.juiceOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Juice Oracle was created by thunder9861, who has been iterating on this oracle for a long time to bring together the best concepts from various solo roleplaying systems.',
                      style: TextStyle(
                        fontSize: 12,
                        color: JuiceTheme.parchment85,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl('https://thunder9861.itch.io/juice-oracle'),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Get the Juice Oracle PDFs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: JuiceTheme.juiceOrange,
                          side: BorderSide(
                            color: JuiceTheme.juiceOrange50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // App Developer
              const SectionHeader(
                icon: Icons.code,
                title: 'App Developer',
                color: JuiceTheme.info,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JuiceTheme.info08,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: JuiceTheme.info25,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brush,
                          size: 18,
                          color: JuiceTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'John Kordich',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: JuiceTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app was independently created by John Kordich, an artist and software engineer who loves all types of games. Built just for fun to make the Juice Oracle more accessible!',
                      style: TextStyle(
                        fontSize: 12,
                        color: JuiceTheme.parchment85,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl('https://github.com/johnkord'),
                            icon: const Icon(Icons.person, size: 16),
                            label: const Text('GitHub'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: JuiceTheme.info,
                              side: BorderSide(
                                color: JuiceTheme.info50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl('https://github.com/johnkord/juice-roll'),
                            icon: const Icon(Icons.code, size: 16),
                            label: const Text('Source'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: JuiceTheme.info,
                              side: BorderSide(
                                color: JuiceTheme.info50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Footer note
              Center(
                child: Text(
                  'Happy adventuring!',
                  style: TextStyle(
                    fontFamily: JuiceTheme.fontFamilySerif,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: JuiceTheme.gold80,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
