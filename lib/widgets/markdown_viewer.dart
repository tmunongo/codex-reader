import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

/// A widget that renders markdown content with syntax highlighting
/// and theme-aware styling.
class MarkdownViewer extends StatelessWidget {
  final String data;
  final bool selectable;

  const MarkdownViewer({super.key, required this.data, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Choose syntax highlighting theme based on app theme
    final codeTheme = isDark ? monokaiSublimeTheme : githubTheme;

    return Markdown(
      data: data,
      selectable: selectable,

      // Enable extensions for better markdown support
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
      ),

      // Custom styling
      styleSheet: MarkdownStyleSheet(
        // Heading styles with Codex branding
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
  }
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
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: HighlightView(
            code,
            language: language,
            theme: codeTheme,
            padding: const EdgeInsets.all(16),
            textStyle: GoogleFonts.jetBrainsMono(fontSize: 14),
          ),
        ),
      );
    }

    // Fallback to default code rendering
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: codeTheme['root']?.backgroundColor ?? Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        code,
        style: GoogleFonts.jetBrainsMono(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
