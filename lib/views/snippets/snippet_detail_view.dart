import 'dart:async';
import 'dart:io';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:code_vault/models/snippet.dart';
import 'package:code_vault/providers/providers.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

class SnippetDetailView extends ConsumerStatefulWidget {
  final Snippet snippet;

  const SnippetDetailView({super.key, required this.snippet});

  @override
  ConsumerState<SnippetDetailView> createState() => _SnippetDetailViewState();
}

class _SnippetDetailViewState extends ConsumerState<SnippetDetailView> {
  late CodeController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Timer? _debounce;
  late Snippet _currentSnippet;

  @override
  void initState() {
    super.initState();
    _currentSnippet = widget.snippet;
    _titleController = TextEditingController(text: _currentSnippet.description);
    _descriptionController = TextEditingController(text: _currentSnippet.fullDescription);
    _codeController = CodeController(text: _currentSnippet.codeContent);

    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
    _codeController.addListener(_onChanged);
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), _saveChanges);
  }

  void _saveChanges() {
    final updatedSnippet = _currentSnippet.copyWith(
      description: _titleController.text,
      fullDescription: _descriptionController.text,
      codeContent: _codeController.text,
      lastModificationDate: DateTime.now(),
    );
    ref.read(snippetListProvider.notifier).updateSnippet(updatedSnippet);
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);
    final savedImagePath = '${appDir.path}/$fileName';

    // Read the image file, resize it, and save it.
    final imageBytes = await pickedFile.readAsBytes();
    final image = img.decodeImage(imageBytes)!;
    // Resize to a more sensible width for mobile performance
    final resizedImage = img.copyResize(image, width: 720);
    await File(savedImagePath).writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

    setState(() {
      _currentSnippet = _currentSnippet.copyWith(mediaPaths: [savedImagePath]);
    });
    _saveChanges();
  }

  void _removeMedia() {
    setState(() {
      _currentSnippet = _currentSnippet.copyWith(mediaPaths: []);
    });
    _saveChanges();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final codeTheme = isDarkMode ? monokaiSublimeTheme : atomOneLightTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.headlineSmall,
                decoration: const InputDecoration.collapsed(hintText: 'Title'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(hintText: 'Description...'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMediaSection(theme, _currentSnippet.mediaPaths),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                color: theme.cardColor,
                child: CodeTheme(
                  data: CodeThemeData(styles: codeTheme),
                  child: CodeField(
                    controller: _codeController,
                    expands: true,
                    lineNumberStyle: const LineNumberStyle(margin: 15),
                    textStyle: const TextStyle(fontFamily: 'monospace'),
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(ThemeData theme, List<String> mediaPaths) {
    if (mediaPaths.isNotEmpty && mediaPaths.first.isNotEmpty) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(mediaPaths.first)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                    onPressed: _pickMedia,
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.delete, color: Colors.white, size: 18),
                    ),
                    onPressed: _removeMedia,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        InkWell(
          onTap: _pickMedia,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 40)),
          ),
        ),
      ],
    );
  }
}
