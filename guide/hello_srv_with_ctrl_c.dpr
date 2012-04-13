program hello_srv_with_ctrl_c;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows, System.SysUtils, ZeroMQ.Wrapper;

var
  Stopped: Boolean;

procedure Run;
var
  Z: IZeroMQ;
  R: IZMQPair;
  S: string;
begin
  Z := TZeroMQ.Create;
  R := Z.Start(ZMQ.Responder);
  R.Bind('tcp://*:5555');
  Writeln('Started hello world server (TCP/5555)...');

  Stopped := False;
  while not Stopped do
  begin
    S := R.ReceiveString([MessageFlag.DontWait]);
    if S <> '' then
    begin
      WriteLn('Received ', S);
      Sleep(10);
      WriteLn(' Sending World');
      R.SendString('World');
    end
    else
      Sleep(1);
  end;
end;

function CatchQuitSignal(CtrlType: DWORD): BOOL; stdcall;
begin
  if CtrlType = CTRL_C_EVENT then
  begin
    WriteLn('Terminating server...');
    Stopped := True;
    Result := True
  end
  else
    Result := False;
end;

begin
  try
    SetConsoleCtrlHandler(@CatchQuitSignal, True);
    Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.