# KLib.Template — Future Enhancements

All original 42 TODOs, 6 bugs (BUG-1..6), 2 features (FEAT-1..2), and 3 optimizations (OPT-1..3) have been implemented.

The engine is production-ready with: 23 statement types, 48+ filters, 16 tests, template inheritance, macros with default/named args, sandbox mode, autoescape, i18n with pluralization, thread-safe MREW locking, token cache with auto-invalidation, custom delimiters, and structured error reporting with line/col.

---

## Future Ideas (not planned)

### Cache: delimiter-aware keys

Currently `setDelimiters()` invalidates the entire cache. A more granular approach would include a delimiter hash in the cache key, allowing templates tokenized with different delimiters to coexist.

### Streaming output

All rendering is in-memory. For very large templates (multi-MB output), a streaming/callback-based API could reduce peak memory:

```pascal
class procedure TTemplate.renderToStream<T>(const templatePath: string;
  const data: T; stream: TStream);
```

### Template linting / validation API

A `validate(templateStr): TArray<TTemplateWarning>` method that parses and checks for common issues (unclosed tags, undefined macros, unused variables) without rendering.

### Locale-aware formatting

The `|date` filter uses a fixed format. Locale-aware number/date formatting (thousands separator, decimal point, date order) would improve i18n support:

```
{{ price | numberformat('de_DE') }}  {# 1.234,56 #}
{{ date | dateformat('it_IT') }}     {# 26 febbraio 2026 #}
```

### Custom tag / extension API

Allow users to register custom statement handlers (not just filters), enabling domain-specific tags without modifying the evaluator:

```pascal
TTemplate.registerTag('chart', myChartHandler);
// Usage: {% chart type="bar" data=items %}
```
