{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerHardware;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand;

type
  THardwareDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  THardwareCommander = class(THardwareDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function ExecuteSQL(var nData: string): Boolean;
    //ִ��SQL���
    function CapturePicture(var nData: string): Boolean;
    //ץ��ͼƬ
    function HYReaderOpenDoor(var nData: string): Boolean;
    //����������򿪵�բ
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
  end;

implementation

uses
  UMgrHardHelper, UTaskMonitor, UMgrCamera, UMgrRFID102;

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function THardwareDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function THardwareDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function THardwareDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure THardwareDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THardwareDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function THardwareCommander.FunctionName: string;
begin
  Result := sBus_HardwareCommand;
end;

constructor THardwareCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor THardwareCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function THardwareCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure THardwareCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function THardwareCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_RemoteExecSQL        : Result := ExecuteSQL(nData);
   cBC_CapturePicture       : Result := CapturePicture(nData);
   cBC_HYReaderOpenDoor     : Result := HYReaderOpenDoor(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//Desc: ִ��SQL���
function THardwareCommander.ExecuteSQL(var nData: string): Boolean;
var nInt: Integer;
begin
  Result := True;
  nInt := gDBConnManager.WorkerExec(FDBConn, PackerDecodeStr(FIn.FData));
  FOut.FData := IntToStr(nInt);
end;

//Date: 2016/8/6
//Parm: ץ��ͨ��(FIn.FData);ץ�ĵ���(FIn.FExtParam)
//Desc: ִ��ץ��
function THardwareCommander.CapturePicture(var nData: string): Boolean;
begin
  Result := True;
  gCameraManager.CapturePicture(FIn.FData, FIn.FExtParam);
end;

//Date: 2016/8/7
//Parm: ���������(FIn.FData)
//Desc: �򿪵�բ
function THardwareCommander.HYReaderOpenDoor(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if not TWorkerBusinessCommander.CallMe(cBC_SaveTruckIn, '�ֶ�̧��', '', @nOut) then
  begin
    nData := '�ֶ�̧��ʧ��: %s';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  Result := True;
  gHYReaderManager.OpenDoor(FIn.FData);
  gCameraManager.CapturePicture(FIn.FData, nOut.FData);
end;

{
��windows�У����ĺ�ȫ���ַ���ռ�����ֽڣ�
����ʹ���� ascii��chart  2  (codes  128 - 255 )��
ȫ���ַ��ĵ�һ���ֽ����Ǳ���Ϊ163��
���ڶ����ֽ����� ��ͬ����ַ������128���������ո񣩡�
����aΪ65����ȫ��a����163����һ���ֽڣ��� 193 ���ڶ����ֽڣ� 128 + 65 ����
�������������������ĵ�һ���ֽڱ���Ϊ����163����
�� ' �� ' Ϊ: 176   162 ��,���ǿ����ڼ�⵽����ʱ������ת����
}

//------------------------------------------------------------------------------
//Date: 2015/11/25
//Parm: 
//Desc: ȫ�Ƿ���ת��Ƿ���
function Dbc2Sbc(const nStr: string):string;
var
  nLen,nIdx:integer;
  nStrTmp,nCStrTmp,nC1,nC2:string;
begin
  nLen:= length(nStr);
  if nLen = 0 then exit;

  nStrTmp  := '';
  nCStrTmp := nStr;
  SetLength(nCStrTmp, nLen + 1);

  nIdx := 1;
  while nIdx<=nLen do
  begin
    nC1 := nCStrTmp[nIdx];
    nC2 := nCStrTmp[nIdx + 1];

    if nC1 = #163 then //ȫ�Ƿ���
    begin
      nStrTmp := nStrTmp + Chr(Ord(nC2[1]) - 128);
      Inc(nIdx, 2);
    end else

    if nC1 > #163 then //����
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161 ) and (nC2 = #161 ) then   // ȫ�ǿո�
    begin
      nStrTmp := nStrTmp + ' ';
      Inc(nIdx, 2 );
    end else

    begin
      nStrTmp := nStrTmp + nC1;
      Inc(nIdx, 1);
    end;
  end;

  Result:= nStrTmp;
end;

//------------------------------------------------------------------------------
//Date: 2015/11/25
//Parm: 
//Desc: ��Ƿ���תȫ�Ƿ���
function Sbc2Dbc(const nStr: string):string;
var
  nLen,nIdx:integer;
  nStrTmp,nCStrTmp,nC1, nC2:string;
begin
  nLen:= length(nStr);
  if nLen = 0 then exit;

  nStrTmp  := '';
  nCStrTmp := nStr;
  SetLength(nCStrTmp, nLen + 1);

  nIdx := 1;
  while nIdx<=nLen do
  begin
    nC1 := nCStrTmp[nIdx];
    nC2 := nCStrTmp[nIdx + 1];

    if nC1 >= #163 then //���� �� ȫ�Ƿ���
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161) and (nC2 = #161) then   // ȫ�ǿո�
    begin
      nStrTmp := nStrTmp +  nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  nC1 = ' ' then   // �ո�
    begin
      nStrTmp := nStrTmp + #161 + #161;
      Inc(nIdx, 1);
    end else

    begin
      nStrTmp := nStrTmp + #163 + Chr(Ord(nC1[1]) + 128);
      Inc(nIdx, 1);
    end;
  end;

  Result:= nStrTmp;
end;
initialization
  gBusinessWorkerManager.RegisteWorker(THardwareCommander, sPlug_ModuleHD);
end.
