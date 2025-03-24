import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/qr_provider.dart';
import 'qr_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;
  bool isFrontCamera = false;

  // Contrôleur d'animation pour le cadre de scan
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation pour le cadre de scan
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final scanAreaSize = screenSize.width * 0.7;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          // Bouton pour le flash
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                controller.toggleTorch();
              });
            },
          ),
          // Bouton pour changer de caméra
          IconButton(
            icon: Icon(
              isFrontCamera ? Icons.camera_front_rounded : Icons.camera_rear_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
                controller.switchCamera();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner de QR code
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  qrProvider.setQrData(code);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QrResultScreen()),
                  );
                }
              }
            },
          ),

          // Overlay semi-transparent
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Zone de scan découpée (transparente)
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.7),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    // Créer un "trou" dans l'overlay
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      // Cette couleur sera "enlevée" pour créer le trou
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // Coins animés
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _buildCorner(
                              size: 30 * _animation.value,
                              topLeft: true,
                              colorScheme: colorScheme,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _buildCorner(
                              size: 30 * _animation.value,
                              topRight: true,
                              colorScheme: colorScheme,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: _buildCorner(
                              size: 30 * _animation.value,
                              bottomLeft: true,
                              colorScheme: colorScheme,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _buildCorner(
                              size: 30 * _animation.value,
                              bottomRight: true,
                              colorScheme: colorScheme,
                            ),
                          ),

                          // Ligne de scan animée
                          _buildScanLine(scanAreaSize),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Instructions en bas
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Placez le QR code dans le cadre',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assurez-vous que le code est bien éclairé et visible dans son intégralité',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bouton flottant pour les paramètres avancés
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanOptions,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.settings_rounded),
      ),
    );
  }

  // Construction d'un coin du cadre de scan
  Widget _buildCorner({
    required double size,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: topLeft || topRight ? BorderSide(color: colorScheme.primary, width: 3) : BorderSide.none,
          left: topLeft || bottomLeft ? BorderSide(color: colorScheme.primary, width: 3) : BorderSide.none,
          right: topRight || bottomRight ? BorderSide(color: colorScheme.primary, width: 3) : BorderSide.none,
          bottom: bottomLeft || bottomRight ? BorderSide(color: colorScheme.primary, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  // Construction de la ligne de scan animée
  Widget _buildScanLine(double width) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.linear,
      builder: (context, value, child) {
        return Positioned(
          top: value * width,
          child: Container(
            height: 14,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {
          // Relancer l'animation
        });
      },
    );
  }

  // Afficher les options de scan
  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScanOptionsSheet(),
    );
  }

  // Construire la feuille des options de scan
  Widget _buildScanOptionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Options de scan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Option pour le flash
          ListTile(
            leading: Icon(
              isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Flash'),
            subtitle: Text(isFlashOn ? 'Activé' : 'Désactivé'),
            trailing: Switch(
              value: isFlashOn,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  isFlashOn = value;
                  controller.toggleTorch();
                });
              },
            ),
          ),

          // Option pour changer de caméra
          ListTile(
            leading: Icon(
              isFrontCamera ? Icons.camera_front_rounded : Icons.camera_rear_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Caméra'),
            subtitle: Text(isFrontCamera ? 'Frontale' : 'Arrière'),
            trailing: Switch(
              value: isFrontCamera,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  isFrontCamera = value;
                  controller.switchCamera();
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Bouton pour fermer les options
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Fermer'),
            ),
          ),

          // Ajouter de l'espace pour les appareils avec une encoche
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}