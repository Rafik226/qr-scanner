import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qrscaner/screens/home_screen.dart';
import 'package:qrscaner/screens/scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/qr_provider.dart';

class QrResultScreen extends StatelessWidget {
  const QrResultScreen({super.key});

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    // S'assurer que l'URL commence par http:// ou https://
    if (urlString.startsWith('www.')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        _showSnackBar(
            context,
            'Impossible d\'ouvrir $urlString',
            isError: true
        );
      }
    } catch (e) {
      _showSnackBar(
          context,
          'Erreur: ${e.toString()}',
          isError: true
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _isUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }

  // Détermine le type de contenu du QR code pour l'affichage approprié
  String _getContentType(String data) {
    if (_isUrl(data)) return 'URL';
    if (_isEmail(data)) return 'Email';
    if (_isPhoneNumber(data)) return 'Numéro de téléphone';
    if (_isVCard(data)) return 'Contact';
    if (_isWifi(data)) return 'Réseau Wi-Fi';
    return 'Texte';
  }

  bool _isEmail(String text) {
    return text.startsWith('mailto:') ||
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  }

  bool _isPhoneNumber(String text) {
    return text.startsWith('tel:') ||
        RegExp(r'^[+]?[\d\s()-]{8,}$').hasMatch(text);
  }

  bool _isVCard(String text) {
    return text.toUpperCase().contains('BEGIN:VCARD');
  }

  bool _isWifi(String text) {
    return text.toUpperCase().startsWith('WIFI:');
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context);
    final String qrData = qrProvider.qrData;
    final bool isUrl = _isUrl(qrData);
    final contentType = _getContentType(qrData);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec le type de contenu
                _buildContentTypeHeader(context, contentType),

                const SizedBox(height: 20),

                // Carte principale avec le contenu
                Expanded(
                  child: Card(
                    elevation: 3,
                    shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Contenu du QR Code',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded),
                                  tooltip: 'Copier le contenu',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: qrData));
                                    _showSnackBar(context, 'Contenu copié dans le presse-papiers');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                ),
                              ),
                              child: SelectableText(
                                qrData,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Actions spécifiques selon le type de contenu
                            if (isUrl) _buildUrlActions(context, qrData),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Actions en bas de page
                _buildBottomActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentTypeHeader(BuildContext context, String contentType) {
    IconData typeIcon;
    Color iconColor = Theme.of(context).colorScheme.primary;

    switch (contentType) {
      case 'URL':
        typeIcon = Icons.link_rounded;
        break;
      case 'Email':
        typeIcon = Icons.email_rounded;
        break;
      case 'Numéro de téléphone':
        typeIcon = Icons.phone_rounded;
        break;
      case 'Contact':
        typeIcon = Icons.contact_page_rounded;
        break;
      case 'Réseau Wi-Fi':
        typeIcon = Icons.wifi_rounded;
        break;
      default:
        typeIcon = Icons.text_fields_rounded;
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                typeIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contentType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Scanné le ${_getCurrentDate()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlActions(BuildContext context, String url) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions pour cette URL',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchUrl(url, context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.open_in_browser_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ouvrir dans le navigateur',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _shortenUrl(url),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Retour'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerScreen()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Nouveau scan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _shortenUrl(String url) {
    // Simplifier l'URL pour l'affichage
    String displayUrl = url;
    if (url.startsWith('http://')) {
      displayUrl = url.substring(7);
    } else if (url.startsWith('https://')) {
      displayUrl = url.substring(8);
    }

    if (displayUrl.startsWith('www.')) {
      displayUrl = displayUrl.substring(4);
    }

    return displayUrl;
  }
}