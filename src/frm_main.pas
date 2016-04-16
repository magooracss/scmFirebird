unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, EditBtn, StdCtrls, ExtCtrls, ComCtrls, Buttons;

const
  _LogFile = 'scmFirebird.log';

  MSG_NO_EXIT_FILE = 'Exit filename empty';
  MSG_NO_DATA = 'Query retrieve 0 records';

type

  FormatMSG = (ERROR, DATA);

  { TfrmMain }

  TfrmMain = class(TForm)
    btnExit: TBitBtn;
    btnRun: TBitBtn;
    dbFile: TFileNameEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    PB: TProgressBar;
    edUser: TEdit;
    edPassword: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    outputFile: TFileNameEdit;
    IBConn: TIBConnection;
    qSQL: TSQLQuery;
    SQLTrans: TSQLTransaction;
    edHost: TEdit;
    procedure btnExitClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
  private
    logFile: TextFile;
    function ConnectDB (fileDB, userDB, passDB, hostDB: string): boolean;

    procedure LogStr (fmsg: FormatMSG; msg: string);

    procedure ProcessQuery (oFile: string);
    function ProcessRow (aRow: string): string;

  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.btnRunClick(Sender: TObject);
begin
  if TRIM(outputFile.Text) = EmptyStr then
  begin
    LogStr(ERROR, MSG_NO_EXIT_FILE);
  end;

  if ConnectDB( TRIM(dbFile.Text)
              , TRIM(edUser.Text)
              , TRIM(edPassword.Text)
              , TRIM(edHost.Text)
              ) then
  begin
    try
      qSQL.Open;
      if (qSQL.RecordCount > 0) then
      begin
        ProcessQuery (outputFile.Text);
      end
      else
        LogStr(ERROR, MSG_NO_DATA);
    except
      on E: Exception do ( LogStr(ERROR, E.Message) );
    end;
  end;
end;

function TfrmMain.ConnectDB(fileDB, userDB, passDB, hostDB: string): boolean;
begin
  Result:= false;
  try
    with ibConn do
    begin
      DatabaseName:= fileDB;
      UserName:= userDB;
      Password:= passDB;
      HostName:= hostDB;
      Open;
      Result:= True;
    end;
  except
    on E: Exception do ( LogStr(ERROR, E.Message) );
  end;
end;

procedure TfrmMain.LogStr(fmsg: FormatMSG; msg: string);
begin
  AssignFile(logFile, ExtractFilePath(Application.ExeName)+ _LOGFILE);
  Append(logFile);
  case fmsg of
   ERROR: WriteLn(logFile, DateToStr(Now) + ' +++ ERROR +++ ' + + msg);
   DATA: WriteLn(logFile,  DateToStr(Now) + ' - ' + msg);
  end;
  CloseFile(logFile);
end;

procedure TfrmMain.ProcessQuery(oFile: string);
begin
  try
    with qSQL do
    begin
      First;
      Pb.Max:= qSQL.RecordCount; //Set the progress bar
      While not EOF do
      begin
        ProcessRow('---');
        Next;
        Pb.StepIt;
      end;
    end;
  except
    on E: Exception do ( LogStr(ERROR, E.Message) );
  end;
end;


//TODO: aRow:string is wrong. This params will be the field of the query
function TfrmMain.ProcessRow(aRow: string): string;
begin
  //
end;

end.

