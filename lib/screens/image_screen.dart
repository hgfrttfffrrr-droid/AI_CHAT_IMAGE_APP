import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/generated_image.dart';
import '../providers/image_gen_provider.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final _promptController = TextEditingController();
  String _selectedSize = '1024x1024';

  static const _sizes = ['1024x1024', '1792x1024', '1024x1792'];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate(ImageGenProvider provider) async {
    final prompt = _promptController.text;
    if (prompt.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    await provider.generate(prompt, size: _selectedSize);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageGenProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Image Generator'),
            actions: [
              IconButton(
                tooltip: 'Clear gallery',
                icon: const Icon(Icons.delete_outline),
                onPressed:
                    provider.images.isEmpty ? null : provider.clearAll,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    children: [
                      TextField(
                        controller: _promptController,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleGenerate(provider),
                        decoration: const InputDecoration(
                          hintText:
                              'Describe an image, e.g. "a cyberpunk city at night in watercolor style"',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSize,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                              ),
                              items: _sizes
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedSize = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: provider.isGenerating
                                ? null
                                : () => _handleGenerate(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: provider.isGenerating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Generate'),
                          ),
                        ],
                      ),
                      if (provider.lastError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            provider.lastError!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: provider.images.isEmpty && !provider.isGenerating
                      ? _EmptyGallery()
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: provider.images.length,
                          itemBuilder: (context, index) {
                            return _ImageCard(image: provider.images[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageCard extends StatelessWidget {
  final GeneratedImage image;
  const _ImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.memory(
                  image.bytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image_outlined),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.55),
                child: Text(
                  image.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(image.bytes),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                image.prompt,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConfig.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.image_outlined,
                  size: 48, color: AppConfig.secondary),
            ),
            const SizedBox(height: 20),
            Text(
              'Create your first AI image',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a description above and tap Generate.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
