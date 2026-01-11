import 'package:flutter/material.dart';

import '../widgets/markdown_viewer.dart';

class MarkdownTestScreen extends StatelessWidget {
  const MarkdownTestScreen({super.key});

  // Sample markdown content covering various features
  static const String sampleMarkdown = '''
# Welcome to Codex

**Codex** is a markdown reader built with Flutter. This document demonstrates various markdown features.

## Text Formatting

You can use *italic*, **bold**, ***bold italic***, and ~~strikethrough~~ text.

Here's a paragraph with a [link to Flutter](https://flutter.dev) and some `inline code`.

## Lists

### Unordered List
- First item
- Second item
  - Nested item
  - Another nested item
- Third item

### Ordered List
1. First step
2. Second step
3. Third step

## Code Blocks

Here's some Dart code:

```dart
void main() {
  print('Hello from Codex!');
  
  final reader = MarkdownReader(
    theme: CodexTheme.dark(),
  );
  
  reader.open('README.md');
}
```

And some Python:

```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print(fibonacci(10))
```

## Blockquotes

> "The purpose of abstraction is not to be vague, but to create a new semantic level in which one can be absolutely precise."
> 
> — Edsger W. Dijkstra

## Tables

| Feature | Status | Priority |
|---------|--------|----------|
| Markdown Rendering | ✅ Done | High |
| Theme System | 🚧 In Progress | High |
| File Browser | ⏳ Planned | Medium |

## Horizontal Rule

---

## Task Lists

- [x] Create project structure
- [x] Implement markdown viewer
- [ ] Add file picker
- [ ] Build theme system

## Image Placeholder

![Codex Logo](placeholder-image.png)
*Images will be supported when loading actual files*

---

**Read the source.** 🚀
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Renderer Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: MarkdownViewer(data: sampleMarkdown),
      ),
    );
  }
}
