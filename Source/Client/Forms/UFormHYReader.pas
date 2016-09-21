{*******************************************************************************
  作者: fendou116688@163.com 2016/8/7
  描述: 门岗读卡器维护记录
*******************************************************************************}
unit UFormHYReader;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormHYReader = class(TfFormNormal)
    EditID: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditHost: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditPort: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    EditMemo: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormHYReader.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormHYReader.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '读卡器 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '读卡器 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormHYReader.FormID: integer;
begin
  Result := cFI_FormHYReaders;
end;

procedure TfFormHYReader.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_HYReader, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
      Exit;

    EditID.Text := FieldByName('H_ID').AsString;
    EditName.Text := FieldByName('H_Name').AsString;
    EditHost.Text := FieldByName('H_Host').AsString;
    EditPort.Text := IntToStr(FieldByName('H_Port').AsInteger);
    EditMemo.Text := FieldByName('H_Memo').AsString;
  end;
end;

//Desc: 保存
procedure TfFormHYReader.BtnOKClick(Sender: TObject);
var nStr,nID,nEvent: string;
begin
  nID := UpperCase(Trim(EditID.Text));
  if nID = '' then
  begin
    ActiveControl := EditID;
    ShowMsg('请输入读卡器编号', sHint);
    Exit;
  end;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  if FTruckID='' then
  begin
    nStr := 'Select * From %s Where H_ID=''%s''';
    nStr := Format(nStr, [sTable_HYReader, nID]);

    if FDM.QueryTemp(nStr).RecordCount>0 then
    begin
      nStr := Format('读卡器[%s]已存在', [nID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;  
  end;  

  nStr := MakeSQLByStr([SF('H_ID', nID),
          SF('H_Name', EditName.Text),
          SF('H_Host', EditHost.Text),
          SF('H_Memo', EditMemo.Text),
          SF('H_Port', StrToIntDef(EditPort.Text, 8000))
          ], sTable_HYReader, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  if FTruckID='' then
        nEvent := '添加[ %s ]档案信息.'
  else  nEvent := '修改[ %s ]档案信息.';
  nEvent := Format(nEvent, [nID]);
  FDM.WriteSysLog(sFlag_CommonItem, nID, nEvent);


  ModalResult := mrOk;
  ShowMsg('读卡器信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormHYReader, TfFormHYReader.FormID);
end.
