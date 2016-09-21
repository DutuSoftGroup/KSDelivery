{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
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
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
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
    //执行SQL语句
    function CapturePicture(var nData: string): Boolean;
    //抓拍图片
    function HYReaderOpenDoor(var nData: string): Boolean;
    //华益读卡器打开道闸
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
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function THardwareDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
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
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function THardwareDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function THardwareDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
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
//Parm: 输入数据
//Desc: 执行nData业务指令
function THardwareCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_RemoteExecSQL        : Result := ExecuteSQL(nData);
   cBC_CapturePicture       : Result := CapturePicture(nData);
   cBC_HYReaderOpenDoor     : Result := HYReaderOpenDoor(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Desc: 执行SQL语句
function THardwareCommander.ExecuteSQL(var nData: string): Boolean;
var nInt: Integer;
begin
  Result := True;
  nInt := gDBConnManager.WorkerExec(FDBConn, PackerDecodeStr(FIn.FData));
  FOut.FData := IntToStr(nInt);
end;

//Date: 2016/8/6
//Parm: 抓拍通道(FIn.FData);抓拍单号(FIn.FExtParam)
//Desc: 执行抓拍
function THardwareCommander.CapturePicture(var nData: string): Boolean;
begin
  Result := True;
  gCameraManager.CapturePicture(FIn.FData, FIn.FExtParam);
end;

//Date: 2016/8/7
//Parm: 读卡器编号(FIn.FData)
//Desc: 打开道闸
function THardwareCommander.HYReaderOpenDoor(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if not TWorkerBusinessCommander.CallMe(cBC_SaveTruckIn, '手动抬杆', '', @nOut) then
  begin
    nData := '手动抬杆失败: %s';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  Result := True;
  gHYReaderManager.OpenDoor(FIn.FData);
  gCameraManager.CapturePicture(FIn.FData, nOut.FData);
end;

{
在windows中，中文和全角字符都占两个字节，
并且使用了 ascii　chart  2  (codes  128 - 255 )。
全角字符的第一个字节总是被置为163，
而第二个字节则是 相同半角字符码加上128（不包括空格）。
如半角a为65，则全角a则是163（第一个字节）、 193 （第二个字节， 128 + 65 ）。
而对于中文来讲，它的第一个字节被置为大于163，（
如 ' 阿 ' 为: 176   162 ）,我们可以在检测到中文时不进行转换。
}

//------------------------------------------------------------------------------
//Date: 2015/11/25
//Parm: 
//Desc: 全角符号转半角符号
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

    if nC1 = #163 then //全角符号
    begin
      nStrTmp := nStrTmp + Chr(Ord(nC2[1]) - 128);
      Inc(nIdx, 2);
    end else

    if nC1 > #163 then //中文
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161 ) and (nC2 = #161 ) then   // 全角空格
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
//Desc: 半角符号转全角符号
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

    if nC1 >= #163 then //中文 或 全角符号
    begin
      nStrTmp := nStrTmp + nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  (nC1 = #161) and (nC2 = #161) then   // 全角空格
    begin
      nStrTmp := nStrTmp +  nC1 + nC2;
      Inc(nIdx, 2);
    end else

    if  nC1 = ' ' then   // 空格
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
