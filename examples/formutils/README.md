# FormUtils Examples

Examples for KLib VCL form components.

## Available Components

### MessageForm
Customizable message dialog with theme support.

```pascal
uses KLib.MessageForm;

var
  params: TMessageFormCreate;
  result: TMessageFormResult;
begin
  params.title := 'Confirm Delete';
  params.text := 'Are you sure you want to delete this item?';
  params.confirmButtonCaption := 'Delete';
  params.cancelButtonCaption := 'Cancel';
  params.colorRGB := '231, 76, 60';  // Red theme
  params.checkboxCaption := 'Don''t ask again';

  result := TMessageForm.showMessage(params);

  if result.isConfirmButtonPressed then
  begin
    if result.isCheckBoxChecked then
      SavePreference('no_delete_confirm', True);
    DeleteItem();
  end;
end;
```

### WaitForm
Loading dialog for long operations.

```pascal
uses KLib.WaitForm;

TWaitForm.showExecuteMethodAndWait(
  procedure
  begin
    // Long-running operation
    ProcessLargeFile();
    GenerateReports();
  end,
  'Processing data, please wait...'
);
```

### RTFForm
RTF viewer with confirmation checkbox.

```pascal
uses KLib.RTFForm;

var
  accepted: Boolean;
begin
  accepted := TRTFForm.show(
    'license.rtf',  // RTF file path
    medium,         // Size: small, medium, large
    True,           // Show checkbox
    'I accept the terms',
    'Accept',
    '52, 152, 219'  // Blue theme
  );

  if accepted then
    ProceedWithInstallation();
end;
```

### PresentationForm
Multi-slide presentation/wizard.

```pascal
uses KLib.PresentationForm;

var
  slides: TJSONPresentationSchema;
begin
  // Load from JSON resource or file
  slides := LoadPresentationJSON('WELCOME_SLIDES');

  TPresentationForm.show(
    slides,
    '52, 152, 219',  // Main color theme
    procedure        // Optional callback on close
    begin
      ShowMessage('Presentation completed!');
    end
  );
end;
```

## Requirements

⚠️ **Important:** FormUtils components require third-party libraries.

Add to Project Options → Conditional Defines:
```
KLIB_RAIZE
```

Required libraries:
- DevExpress VCL (v15.2.4+)
- Raize Components

See [main README](../../README.md#optional-dependencies) for details.

## Creating Examples

Example projects coming soon! Meanwhile, refer to the code snippets above.

## See Also

- [KLib.MessageForm.pas](../../KLib.MessageForm.pas)
- [KLib.WaitForm.pas](../../KLib.WaitForm.pas)
- [KLib.RTFForm.pas](../../KLib.RTFForm.pas)
- [KLib.PresentationForm.pas](../../KLib.PresentationForm.pas)
