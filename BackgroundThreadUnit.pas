unit BackgroundThreadUnit;

interface

uses
  System.Classes;

type
  TBackgroundThread = class(TThread)
  private
    FPaused: Boolean;
    // FTerminated: Boolean;
    // FOnTerminate: TNotifyEvent;
  protected
    procedure Execute; override;
  public
    procedure Pause;
    procedure Continue;
    // procedure Terminate;
    // property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

procedure TBackgroundThread.Continue;
begin
  FPaused := False;
end;

  // process something here
procedure TBackgroundThread.Execute;
var
  LogFile: TextFile;
begin
  try
    FPaused := False;
    AssignFile(LogFile, 'C:\Temp\Logs.log');
    Rewrite(LogFile);

    while not Terminated do
    begin
      if not FPaused then
      begin
        WriteLn(LogFile, 'Logs From Background Thread: ' + DateTimeToStr(Now));
      end;
      TThread.Sleep(1000);
    end;
  finally
    CloseFile(LogFile);
  end;
end;

procedure TBackgroundThread.Pause;
begin
  FPaused := True;
end;

end.
