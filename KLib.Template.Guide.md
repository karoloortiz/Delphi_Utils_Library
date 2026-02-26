# KLib.Template — Quick Guide

A Jinja2-inspired template engine for Delphi. Render HTML, emails, reports or any text from templates with variables, loops, conditionals, filters and template inheritance — all native, no external dependencies.

---

## Getting Started

### 1. Basic rendering

```pascal
uses KLib.Template;

type
  TGreeting = record
    name: string;
    year: Integer;
  end;

var
  _data: TGreeting;
begin
  _data.name := 'World';
  _data.year := 2026;

  ShowMessage(TTemplate.render<TGreeting>('Hello {{ name }}, welcome to {{ year }}!', _data));
  // Output: Hello World, welcome to 2026!
end;
```

### 2. Rendering from file

```pascal
// template.html:
//   <h1>{{ title }}</h1>
//   <p>{{ body }}</p>

Result := TTemplate.renderFromFile<TPageData>('templates\page.html', _data);
```

The file is read once, tokenized, and **cached automatically**. Subsequent calls with the same path skip I/O and parsing — only evaluation is repeated.

---

## Template Syntax

### Variables

```
{{ user.name }}
{{ items[0].price }}
{{ @root.globalVar }}
```

### Filters

Filters transform values using the pipe `|` operator. They can be chained:

```
{{ name | upper }}
{{ description | escape }}
{{ price | round | default(0) }}
{{ items | sort(attribute='name') | join(', ') }}
{{ content | trim | truncate(100) }}
```

**48+ built-in filters** including: `upper`, `lower`, `capitalize`, `title`, `trim`, `escape`, `nl2br`, `strip_tags`, `urlencode`, `reverse`, `length`, `join`, `split`, `sort`, `unique`, `first`, `last`, `batch`, `sum`, `min`, `max`, `map`, `select`, `reject`, `groupby`, `default`, `int`, `float`, `round`, `abs`, `date`, `base64encode`, `md5`, `sha256`, `filesizeformat`, `xmlattr`, and more.

### Conditionals

```
{% if user.isAdmin %}
  <span class="badge">Admin</span>
{% elif user.isEditor %}
  <span class="badge">Editor</span>
{% else %}
  <span class="badge">User</span>
{% endif %}
```

**Operators:** `==`, `!=`, `>`, `<`, `>=`, `<=`, `and`, `or`, `not`, `in`, `not in`

**Tests:** `is defined`, `is none`, `is empty`, `is odd`, `is even`, `is divisibleby(n)`, `is startswith(s)`, `is endswith(s)`, `is contains(s)`, `is match(regex)`, `is iterable`, `is number`, `is string`

### Loops

```
{% for item in items %}
  {{ loop.index }}. {{ item.name }} — {{ item.price }}
{% endfor %}
```

**Loop variables:** `loop.index` (1-based), `loop.index0` (0-based), `loop.first`, `loop.last`, `loop.length`, `loop.revindex`, `loop.previtem`, `loop.nextitem`, `loop.depth`

**Loop features:** `for...if` filtering, `{% else %}` for empty collections, `{% break %}`, `{% continue %}`, `{% sep %}...{% endsep %}` (separator between items), recursive loops

### Set variables

```
{% set greeting = 'Hello ' ~ user.name %}
{{ greeting }}

{% set content %}
  This entire block is captured as a string.
{% endset %}
```

### Template inheritance

**base.html:**
```html
<html>
<head><title>{% block title %}Default{% endblock %}</title></head>
<body>
  {% block content %}{% endblock %}
</body>
</html>
```

**page.html:**
```html
{% extends 'base.html' %}
{% block title %}My Page{% endblock %}
{% block content %}
  <h1>Hello!</h1>
  {{ super() }}  {# renders parent block content #}
{% endblock %}
```

### Include

```
{% include 'header.html' %}
{% include 'sidebar.html' ignore missing %}
```

### Macros (reusable components)

```
{% macro button(label, type='primary') %}
  <button class="btn btn-{{ type }}">{{ label }}</button>
{% endmacro %}

{{ button('Save') }}
{{ button('Delete', 'danger') }}
```

Import macros from other files:
```
{% from 'components.html' import button, card %}
{% import 'helpers.html' as h %}
{{ h.formatPrice(100) }}
```

### Other statements

| Statement | Purpose |
|-----------|---------|
| `{% switch %}...{% case %}...{% default %}...{% endswitch %}` | Switch/case |
| `{% with x = expr %}...{% endwith %}` | Local scope |
| `{% filter upper %}...{% endfilter %}` | Apply filter to block |
| `{% autoescape true %}...{% endautoescape %}` | Toggle HTML escaping |
| `{% raw %}...{% endraw %}` | Output without processing |
| `{% compress %}...{% endcompress %}` | Collapse whitespace |
| `{% attempt %}...{% recover %}...{% endattempt %}` | Error handling |
| `{% while condition %}...{% endwhile %}` | While loop |
| `{% do expression %}` | Evaluate, discard result |
| `{% stop %}` | Stop rendering |
| `{% debug %}` | Dump scope variables |
| `{% trans %}...{% pluralize %}...{% endtrans %}` | i18n with pluralization |

### Comments

```
{# This is a comment — not rendered #}
```

### Whitespace control

Trim whitespace with `-`:
```
{%- if true -%}
  no surrounding whitespace
{%- endif -%}
```

### Ternary expressions

```
{{ 'Active' if user.enabled else 'Disabled' }}
```

### Literals

```
{{ [1, 2, 3] }}                    {# array #}
{{ {'key': 'value', 'n': 42} }}    {# dictionary #}
{{ range(5) }}                     {# [0, 1, 2, 3, 4] #}
{{ namespace(count=0) }}           {# mutable dict for loops #}
```

---

## Configuration API

All configuration is **global** and **thread-safe** (MREW lock).

### HTML Autoescape

```pascal
// Enable globally — all {{ }} output is HTML-escaped
TTemplate.setAutoescape(True);
```

Use `| safe` in the template to bypass escaping for trusted HTML:
```
{{ trustedHtml | safe }}
{{ userInput }}            {# escaped automatically #}
```

### Undefined variable handling

```pascal
TTemplate.setUndefinedMode(umSilent);   // default: empty string
TTemplate.setUndefinedMode(umStrict);   // raise ETemplateError
TTemplate.setUndefinedMode(umDebug);    // output {{ undefined: varName }}
```

### Global variables

Available in every render call:

```pascal
TTemplate.setGlobal('appName', 'My Application');
TTemplate.setGlobal('version', 3);
```

```
<footer>{{ appName }} v{{ version }}</footer>
```

### Search paths for includes/extends

```pascal
TTemplate.addSearchPath('C:\templates');
TTemplate.addSearchPath('C:\templates\shared');
```

### Custom delimiters

```pascal
TTemplate.setDelimiters('${', '}$', '<%', '%>');
// Now: ${ variable }$ and <% if condition %>...<% endif %>
```

### Custom filters

```pascal
// String filter
TTemplate.registerFilter('shout', function(const value: string; const args: TArray<string>): string
begin
  Result := UpperCase(value) + '!!!';
end);

// TValue filter (for complex types)
TTemplate.registerFilterV('double', function(const value: TValue; const args: TArray<string>): TValue
begin
  Result := TValue.From<Integer>(value.AsInteger * 2);
end);
```

```
{{ name | shout }}     {# WORLD!!! #}
{{ count | double }}   {# 10 → 20 #}
```

### Sandbox mode

Restricts filesystem access and limits recursion/output size:

```pascal
TTemplate.setSandbox(True);
// Blocks: include, extends, import
// Limits: 50 recursion depth, 1MB output
```

### Cache control

```pascal
TTemplate.precompile('templates\report.html');  // pre-tokenize
TTemplate.clearCache;                           // invalidate all
```

---

## Data Binding with Records

The engine uses Delphi RTTI to read record fields. Define your data as records:

```pascal
type
  TOrderItem = record
    name: string;
    quantity: Integer;
    price: Double;
  end;

  TOrder = record
    number: string;
    customer: string;
    items: TArray<TOrderItem>;
    total: Double;
  end;
```

```html
<h1>Order #{{ number }}</h1>
<p>Customer: {{ customer }}</p>
<table>
  {% for item in items %}
  <tr>
    <td>{{ item.name }}</td>
    <td>{{ item.quantity }}</td>
    <td>{{ item.price }}</td>
  </tr>
  {% endfor %}
</table>
<p><strong>Total: {{ total }}</strong></p>
```

```pascal
var _order: TOrder;
// ... fill _order ...
Result := TTemplate.renderFromFile<TOrder>('templates\order.html', _order);
```

---

## Error Handling

Errors include template name, line and column for easy debugging:

```pascal
try
  Result := TTemplate.renderFromFile<TData>('page.html', _data);
except
  on E: ETemplateError do
    ShowMessage(Format('Template error in %s at line %d, col %d: %s',
      [E.templateName, E.line, E.col, E.Message]));
end;
```

---

## Architecture

```
KLib.Template.pas           → Public API (TTemplate class)
KLib.Template.Lexer.pas     → Tokenizer (template string → tokens)
KLib.Template.Evaluator.pas → Evaluator (tokens + data → output)
KLib.Template.Filters.pas   → 48+ built-in filters + custom filter registry
KLib.Template.Cache.pas     → Token cache with auto-invalidation
KLib.Template.Exceptions.pas→ ETemplateError with line/col info
```

All state is protected by a `TMultiReadExclusiveWriteSynchronizer` — multiple renders can execute in parallel, while configuration changes are exclusive.
