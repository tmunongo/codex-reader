import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' as hl;
import 'package:markdown/markdown.dart' as md;

class MarkdownViewer extends StatelessWidget {
  final String data;
  final bool selectable;

  static const int maxRecommendedLength = 500000;

  const MarkdownViewer({super.key, required this.data, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    if (data.length > maxRecommendedLength) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: .1),
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This file is very large (${(data.length / 1024).toStringAsFixed(0)}KB). '
                    'Rendering may be slow.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMarkdown(context, data, selectable)),
        ],
      );
    }

    return _buildMarkdown(context, data, selectable);
  }
}

@override
Widget _buildMarkdown(BuildContext context, String data, bool selectable) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final codeTheme = isDark ? monokaiSublimeTheme : githubTheme;

  Widget markdownWidget = Markdown(
    data: data,
    selectable:
        false, // Force false to use Text widgets, handled by SelectionArea

    extensionSet: md.ExtensionSet(
      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
    ),

    styleSheet: MarkdownStyleSheet(
      h1: GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h2: GoogleFonts.jetBrainsMono(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h3: GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h4: GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h5: GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h6: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).round()),
        height: 1.3,
      ),

      // Body text
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),

      // Links
      a: TextStyle(
        color: const Color(0xFF00D9FF), // Codex cyan
        decoration: TextDecoration.underline,
      ),

      // Code styling
      code: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        backgroundColor: isDark
            ? const Color(0xFF1A1A24)
            : const Color(0xFFF5F5F5),
        color: const Color(0xFFFFB86C), // Amber accent
      ),

      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),

      codeblockPadding: const EdgeInsets.all(16),

      // Blockquotes
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 4),
        ),
      ),
      blockquotePadding: const EdgeInsets.all(16),

      // Lists
      listBullet: TextStyle(color: theme.colorScheme.primary, fontSize: 16),

      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
            width: 1,
          ),
        ),
      ),

      // Tables
      tableBody: theme.textTheme.bodyMedium,
      tableHead: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
      ),
      tableCellsPadding: const EdgeInsets.all(12),
    ),

    // Custom code block builder for syntax highlighting
    builders: {'code': CodeBlockBuilder(codeTheme: codeTheme)},
  );

  return selectable ? SelectionArea(child: markdownWidget) : markdownWidget;
}

/// Custom builder for syntax-highlighted code blocks
class CodeBlockBuilder extends MarkdownElementBuilder {
  final Map<String, TextStyle> codeTheme;

  CodeBlockBuilder({required this.codeTheme});

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';
    final code = element.textContent;

    // If language is specified, use syntax highlighting
    if (language.isNotEmpty && language != 'plaintext') {
      try {
        var result = hl.highlight.parse(code, language: language);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                codeTheme['root']?.backgroundColor ?? const Color(0xff23241f),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              TextSpan(
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: codeTheme['root']?.color ?? const Color(0xfff8f8f2),
                ),
                children: _convert(result.nodes!, codeTheme),
              ),
            ),
          ),
        );
      } catch (e) {
        // Fallback if parsing fails
        debugPrint('Highlight parsing failed: $e');
      }
    }

    // Fallback to default code rendering
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: codeTheme['root']?.backgroundColor ?? Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: GoogleFonts.jetBrainsMono(fontSize: 14, color: Colors.white),
      ),
    );
  }

  List<InlineSpan> _convert(List<hl.Node> nodes, Map<String, TextStyle> theme) {
    List<InlineSpan> spans = [];
    for (var node in nodes) {
      if (node.value != null) {
        spans.add(TextSpan(text: node.value));
      } else if (node.children != null) {
        spans.add(
          TextSpan(
            style: theme[node.className],
            children: _convert(node.children!, theme),
          ),
        );
      }
    }
    return spans;
  }
}
