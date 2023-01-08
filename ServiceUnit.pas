unit ServiceUnit;

interface

uses
  Winapi.Windows
, Winapi.Messages
, System.SysUtils
, System.Classes
, Vcl.Graphics
, Vcl.Controls
, Vcl.SvcMgr
, Vcl.Dialogs
, BackgroundThreadUnit
, System.Win.Registry;

type
  TService1 = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
  private
    FBackgroundThread: TBackgroundThread;
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

{$R *.dfm}

var
  MyService: TService1;

implementation

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MyService.Controller(CtrlCode);
end;

procedure TService1.ServiceExecute(Sender: TService);
begin
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(false);
    TThread.Sleep(1000);
  end;
end;

function TService1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TService1.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  FBackgroundThread.Continue;
  Continued := True;
end;

procedure TService1.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + name, false) then
    begin
      Reg.WriteString('Description', 'Blogs.Embarcadero.com');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TService1.ServicePause(Sender: TService; var Paused: Boolean);
begin
  FBackgroundThread.Pause;
  Paused := True;
end;

procedure TService1.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FBackgroundThread.Terminate;
  FBackgroundThread.WaitFor;
  FreeAndNil(FBackgroundThread);
  Stopped := True;
end;

procedure TService1.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FBackgroundThread := TBackgroundThread.Create(True);
  FBackgroundThread.Start;
  Started := True;
end;

end.
