import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:website/src/html_stub.dart' if (dart.library.html) 'dart:html';
import 'dart:typed_data';
import 'dart:async';

class Vlmidentification extends StatefulWidget {
  const Vlmidentification({super.key});

  @override
  State<Vlmidentification> createState() => _VlmidentificationState();
}

class _VlmidentificationState extends State<Vlmidentification>
    with SingleTickerProviderStateMixin {
  // Image handling
  dynamic _selectedImage;
  String? _imagePreviewUrl;
  bool _isProcessing = false;
  bool _hasResults = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Results data
  Map<String, dynamic> _identificationResults = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_imagePreviewUrl != null && _imagePreviewUrl!.startsWith('blob:')) {
      Url.revokeObjectUrl(_imagePreviewUrl!);
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final FileUploadInputElement input = FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          if (file.size > 10 * 1024 * 1024) {
            _showSnackBar(
              'Image too large. Please select an image under 10MB.',
              Colors.orange,
            );
            return;
          }

          setState(() {
            _selectedImage = file;
            if (_imagePreviewUrl != null &&
                _imagePreviewUrl!.startsWith('blob:')) {
              Url.revokeObjectUrl(_imagePreviewUrl!);
            }
            _imagePreviewUrl = Url.createObjectUrl(file);
            _hasResults = false;
          });
        }
      });
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    }
  }

  Future<void> _processImage() async {
    if (_imagePreviewUrl == null) {
      _showSnackBar('Please upload an image first', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasResults = false;
    });

    _animationController.reset();
    _animationController.forward();

    // Simulate VLM processing with progressive steps
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _identificationResults = {
        'scientificName': 'Prunus africana',
        'commonName': 'African Cherry',
        'family': 'Rosaceae',
        'confidence': 0.952,
        'visualFeatures': [
          'Leaf morphology detected - elliptic, alternate arrangement',
          'Bark texture analyzed - rough, dark brown with lenticels',
          'Growth pattern identified - evergreen tree, 10-25m height',
          'Color spectrum matched - dark green foliage, reddish bark',
        ],
        'medicinalProperties': [
          'Prostate health - Used for benign prostatic hyperplasia',
          'Anti-inflammatory - Reduces inflammation and swelling',
          'Urinary tract health - Treats urinary disorders',
        ],
        'culturalContext': {
          'location': 'Bwindi Forest Ecosystem',
          'significance':
              'Endangered species with significant medicinal value in East African traditional medicine',
          'traditionalKnowledge':
              'Sustainable harvesting practices developed by local communities over generations',
        },
        'communityValidation': [
          {
            'type': 'Traditional Use',
            'description':
                'Documented by community elder from Bakiga community',
            'validated': true,
          },
          {
            'type': 'Cultural Significance',
            'description':
                'Important in Bakiga traditional medicine for male reproductive health',
            'validated': true,
          },
          {
            'type': 'Traditional Knowledge',
            'description':
                'Conservation efforts integrated with traditional knowledge preservation',
            'validated': true,
          },
        ],
        'semanticTraceability': [
          'Visual features extracted using CLIP-based vision encoder',
          'Botanical nodes matched against knowledge graph (confidence: 95.2%)',
          'Cultural narratives retrieved via semantic relationship traversal',
          'All source artifacts have cryptographic provenance tracking',
        ],
      };
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isProcessing = false;
      _hasResults = true;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isMobile
                ? Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildUploadSection(),
                      const SizedBox(height: 24),
                      if (_isProcessing) _buildProcessingSection(),
                      if (_hasResults && !_isProcessing) _buildResultsSection(),
                      if (!_hasResults &&
                          !_isProcessing &&
                          _imagePreviewUrl == null)
                        _buildInfoSection(),
                    ],
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildUploadSection()),
                          if (_isProcessing || _hasResults)
                            Expanded(
                              flex: 1,
                              child: _isProcessing
                                  ? _buildProcessingSection()
                                  : _buildResultsSection(),
                            ),
                          if (!_hasResults &&
                              !_isProcessing &&
                              _imagePreviewUrl == null)
                            Expanded(flex: 1, child: _buildInfoSection()),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Knowledge-Grounded Vision-Language Model',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a plant image to experience VLM-powered identification grounded in cultural context. The system retrieves botanical taxonomies and associated cultural narratives from the knowledge graph.',
                    style: TextStyle(color: Colors.green.shade700, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Plant Image',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image Preview Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade200, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.shade50,
                ),
                child: _imagePreviewUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 64,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Click to upload plant image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Supports JPG, PNG (Max 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade400,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imagePreviewUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_imagePreviewUrl != null &&
                                        _imagePreviewUrl!.startsWith('blob:')) {
                                      Url.revokeObjectUrl(_imagePreviewUrl!);
                                    }
                                    _selectedImage = null;
                                    _imagePreviewUrl = null;
                                    _hasResults = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Process Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _imagePreviewUrl != null && !_isProcessing
                    ? _processImage
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  disabledBackgroundColor: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Identify Plant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                Text(
                  'VLM Pipeline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Processing steps
            _buildProcessingStep(
              1,
              'Visual Feature Extraction',
              'Analyzing leaf morphology, bark texture, and color patterns...',
            ),
            _buildProcessingStep(
              2,
              'Botanical Node Mapping',
              'Matching features against knowledge graph...',
            ),
            _buildProcessingStep(
              3,
              'Cultural Narrative Retrieval',
              'Retrieving traditional knowledge and cultural context...',
            ),
            _buildProcessingStep(
              4,
              'Community Validation Check',
              'Cross-referencing with community-validated data...',
            ),

            const SizedBox(height: 24),

            // Progress bar
            LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.green.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Processing... ${(_progressAnimation.value * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.green.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingStep(int step, String title, String description) {
    final isActive = _progressAnimation.value >= (step - 1) * 0.25;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green.shade600 : Colors.green.shade100,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      step.toString(),
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.green.shade800
                        : Colors.green.shade600,
                  ),
                ),
                if (isActive)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final results = _identificationResults;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Identification Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plant Name Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      results['scientificName'] ?? 'Prunus africana',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      results['commonName'] ?? 'African Cherry',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      results['family'] ?? 'Rosaceae',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Confidence: ${((results['confidence'] ?? 0.952) * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Visual Features
              _buildSection(
                title: 'Visual Features Detected',
                icon: Icons.visibility,
                color: Colors.blue,
                children: (results['visualFeatures'] as List).map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Medicinal Properties
              _buildSection(
                title: 'Medicinal Properties',
                icon: Icons.local_hospital,
                color: Colors.red,
                children: (results['medicinalProperties'] as List).map((
                  property,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.healing, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(property)),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Cultural Context
              _buildSection(
                title: 'Cultural Context & Traditional Knowledge',
                icon: Icons.article,
                color: Colors.purple,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📍 ${results['culturalContext']['location']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          results['culturalContext']['significance'],
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          results['culturalContext']['traditionalKnowledge'],
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Community Validation
              _buildSection(
                title: 'Community Validated',
                icon: Icons.people,
                color: Colors.orange,
                children: (results['communityValidation'] as List).map((
                  validation,
                ) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                validation['type'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              Text(
                                validation['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Semantic Traceability
              _buildSection(
                title: 'Semantic Traceability',
                icon: Icons.account_tree,
                color: Colors.teal,
                children: (results['semanticTraceability'] as List).map((
                  trace,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(child: Text(trace)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color.shade700),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Ready for VLM Processing',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Upload a plant image to see knowledge-grounded identification in action',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Robustness Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Robustness & Evaluation Protocol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoBullet(
                    'Device-Held-Out Splits',
                    'Models are tested on low-quality smartphone cameras not seen during training, ensuring generalization across varying tourist hardware.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoBullet(
                    'Spatial-Held-Out Splits',
                    'Training on flora from Mpanga forest, testing zero-shot on Mabira forest to ensure resilience to geographic distribution shifts.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
