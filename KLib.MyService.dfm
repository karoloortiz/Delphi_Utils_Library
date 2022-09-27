object MyService: TMyService
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'MyService'
  AfterInstall = ServiceAfterInstall
  AfterUninstall = ServiceAfterUninstall
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 225
  Width = 323
  PixelsPerInch = 144
end
