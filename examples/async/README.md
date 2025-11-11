# Async Examples

Examples demonstrating KLib async/promise functionality.

## Available Examples

### example-1-async.zip

Complete demo project showing:
- **TPromise** - JavaScript-style promises with resolve/reject
- **promisify()** - Convert any method to async
- **TPromise.All** - Wait for multiple promises
- **asyncifyMethod** - Simple async execution
- **TAsyncMethod** - Object-oriented async wrapper
- **TAsyncMethods** - Parallel execution manager

## Running the Examples

1. Extract the zip file
2. Open the `.dproj` file in Delphi
3. Build and run

## Quick Snippets

### Basic Promise

```pascal
uses KLib.Promise;

TPromise.Create(
  procedure(resolve: TCallBack; reject: TCallBack)
  begin
    // Background work
    try
      DoSomething();
      resolve('Success');
    except
      on E: Exception do
        reject(E.Message);
    end;
  end,
  procedure(value: string)  // then
  begin
    ShowMessage('Done: ' + value);
  end,
  procedure(value: string)  // catch
  begin
    ShowMessage('Error: ' + value);
  end
);
```

### Promise Chaining

```pascal
TPromise.Create(...)
  ._then(procedure(value: string)
    begin
      // Step 1
      ProcessData(value);
    end)
  ._then(procedure(value: string)
    begin
      // Step 2
      SaveResults(value);
    end)
  ._catch(procedure(error: string)
    begin
      LogError(error);
    end)
  ._finally;
```

### Promise.All

```pascal
uses KLib.Promise.All;

TPromise.all([
  procedure begin FetchUserData; end,
  procedure begin FetchOrders; end,
  procedure begin FetchProducts; end
])
._then(procedure(value: string)
  begin
    ShowMessage('All data loaded!');
  end)
._finally;
```

## See Also

- [Promise Documentation](../../README.md#promises--async)
- [KLib.Promise.pas](../../KLib.Promise.pas)
- [KLib.Asyncify.pas](../../KLib.Asyncify.pas)
